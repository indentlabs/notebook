class Rack::Attack
  DOCUMENT_UNLOCK_PATH = %r{\A/documents/(\d+)/unlock/?\z}i

  # Production's cache lives in files on each server, so counters have to be kept somewhere shared
  Rack::Attack.cache.store = if Rails.env.production?
    ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'), namespace: 'rack_attack')
  else
    ActiveSupport::Cache::MemoryStore.new
  end

  # Normalized the way the router sees it, so that spellings like //documents/01/unlock
  # or /documents/%31/unlock count against the same document's limits.
  def self.document_unlock_id(req)
    return unless req.post?

    Rack::Utils.unescape_path(req.path).squeeze('/')[DOCUMENT_UNLOCK_PATH, 1]&.to_i
  end

  # Guessing a document's password. These only match the unlock path, so nothing else touches Redis.
  throttle('document_unlock/ip', limit: 10, period: 1.minute) { |req| req.ip if document_unlock_id(req) }
  throttle('document_unlock/document', limit: 30, period: 1.minute) { |req| document_unlock_id(req) }

  # Each attempt ties up a Puma thread for a slow bcrypt check, so this keeps a flood of them
  # spread across many documents from taking the site down.
  throttle('document_unlock/site', limit: 300, period: 1.minute) { |req| 'all' if document_unlock_id(req) }

  # Back to the lock screen, which explains what happened
  self.throttled_responder = lambda do |req|
    [302, { 'Location' => "/documents/#{document_unlock_id(req)}?too_many_attempts=1" }, []]
  end
end
