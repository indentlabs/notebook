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

  def enqueue_word_count_jobs
    # Cache the updated word count on this attribute
    CacheAttributeWordCountJob.perform_later(self.id)

    # Cache the updated word count on the page this attribute belongs to
    CacheSumAttributeWordCountJob.perform_later(self.entity_type, self.entity_id)
  rescue RedisClient::CannotConnectError, Redis::CannotConnectError => e
    Rails.logger.error "[WordCount] Redis unavailable - word count jobs not enqueued for Attribute##{id}: #{e.message}"
    # No inline fallback - would be DDoS risk with large documents
  end

  after_save do
    entity.touch
  end
end
