class Attribute < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :attribute_field
  belongs_to :entity, polymorphic: true, touch: true

  validates :attribute_field_id, uniqueness: {
    scope: [:entity_type, :entity_id],
    conditions: -> { where(deleted_at: nil) },
    message: "already has a value for this entity"
  }

  include HasChangelog

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  include HasPrivacy

  after_save do
    if self.attribute_field.field_type == 'universe' && self.value.present?
      entity.update(universe_id: self.value.to_i)
      # todo probably need permissions service here also
    end
  end

  after_commit :enqueue_word_count_jobs, on: [:create, :update]
  after_commit :recount_page_after_removal, on: :destroy

  # How long a page waits to be recounted after a field is deleted, so deleting a whole category
  # (or a template field across every page) recounts each page once rather than once per field.
  REMOVAL_RECOUNT_DELAY = 1.minute

  def enqueue_word_count_jobs
    # Recount this field, then the page it belongs to (in that order, in one job). A field that has
    # never had its count cached also sends the count of its text from before this edit, so the
    # page's day starts from the right count.
    previous_word_count = if word_count_cache.nil? && CacheAttributeWordCountJob::NON_PROSE_FIELD_TYPES.exclude?(attribute_field&.field_type)
      WordCountService.count_with_fallback(value_before_last_save)
    end
    CacheAttributeWordCountJob.perform_later(self.id, recount_page: true, previous_word_count: previous_word_count)
  rescue RedisClient::CannotConnectError, Redis::CannotConnectError => e
    Rails.logger.error "[WordCount] Redis unavailable - word count jobs not enqueued for Attribute##{id}: #{e.message}"
    # No inline fallback - would be DDoS risk with large documents
  end

  # A deleted field's words no longer count towards its page. Without a recount, the page's total
  # stayed too high, and the next day's writing on it was cancelled out by the "missing" words.
  def recount_page_after_removal
    return unless CacheLock.acquire("word_counts/#{entity_type}/#{entity_id}/recount", expires_in: REMOVAL_RECOUNT_DELAY)

    CacheSumAttributeWordCountJob.set(wait: REMOVAL_RECOUNT_DELAY).perform_later(entity_type, entity_id)
  rescue RedisClient::Error, Redis::BaseError => e
    Rails.logger.error "[WordCount] Redis unavailable - page recount not enqueued after deleting Attribute##{id}: #{e.message}"
  end

  after_save do
    entity.touch
  end
end
