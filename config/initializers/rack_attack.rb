class Rack::Attack
  DOCUMENT_UNLOCK_PATH = %r{\A/documents/(\d+)/unlock/?\z}i

  # Every page type's unlock route, e.g. /plan/characters/12/unlock. Built from the route names
  # rather than content_types, which aren't configured yet when this file loads.
  PAGE_UNLOCK_PATH = %r{\A/plan/(#{Rails.application.config.content_type_names[:all].map { |name| Regexp.escape(name.downcase.pluralize) }.join('|')})/(\d+)/unlock/?\z}i

  # Production's cache lives in files on each server, so counters have to be kept somewhere shared
  Rack::Attack.cache.store = if Rails.env.production?
    ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'), namespace: 'rack_attack')
  else
    ActiveSupport::Cache::MemoryStore.new
  end

  # Normalized the way the router sees it, so that spellings like //documents/01/unlock
  # or /documents/%31/unlock count against the same document's limits.
  def self.normalized_path(req)
    Rack::Utils.unescape_path(req.path).squeeze('/')
  end

  def self.document_unlock_id(req)
    return unless req.post?

    normalized_path(req)[DOCUMENT_UNLOCK_PATH, 1]&.to_i
  end

  # The page an unlock attempt is for, as e.g. "characters/12", or nil if it isn't one
  def self.page_unlock_key(req)
    return unless req.post?

    match = normalized_path(req).match(PAGE_UNLOCK_PATH)
    "#{match[1].downcase}/#{match[2].to_i}" if match
  end

  # Cloudflare is in front of the site, so req.ip is one of its addresses or a proxy's, not the reader's.
  # A request that skips Cloudflare could fake this header, but that only gets it around the per-visitor limit.
  def self.visitor_ip(req)
    req.get_header('HTTP_CF_CONNECTING_IP').presence || req.ip
  end

  def self.unlock_attempt?(req)
    document_unlock_id(req).present? || page_unlock_key(req).present?
  end

  # Guessing a document's or page's password. These only match the unlock paths, so nothing else
  # touches Redis. A visitor's limit covers documents and pages together.
  throttle('document_unlock/ip', limit: 10, period: 1.minute) { |req| visitor_ip(req) if unlock_attempt?(req) }
  throttle('document_unlock/document', limit: 30, period: 1.minute) { |req| document_unlock_id(req) }
  throttle('page_unlock/page', limit: 30, period: 1.minute) { |req| page_unlock_key(req) }

  # Each attempt ties up a Puma thread for a slow bcrypt check, so this keeps a flood of them
  # spread across many documents and pages from taking the site down. Both kinds share it.
  throttle('document_unlock/site', limit: 300, period: 1.minute) { |req| 'all' if unlock_attempt?(req) }

  # Back to the lock screen, which explains what happened
  self.throttled_responder = lambda do |req|
    location = if (page = page_unlock_key(req))
      "/plan/#{page}?too_many_attempts=1"
    else
      "/documents/#{document_unlock_id(req)}?too_many_attempts=1"
    end

    [302, { 'Location' => location }, []]
  end
end
