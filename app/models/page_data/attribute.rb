class Attribute < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :attribute_field
  belongs_to :entity, polymorphic: true, touch: true

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

  after_commit do
    if saved_changes.key?('value')
      # Cache the updated word count on this attribute
      CacheAttributeWordCountJob.perform_later(self.id)

      # Cache the updated word count on the page this attribute belongs to
      CacheSumAttributeWordCountJob.perform_later(self.entity_type, self.entity_id)
    end
  end

  after_save do
    entity.touch
  end
end
