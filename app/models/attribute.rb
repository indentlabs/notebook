class Attribute < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :attribute_field
  belongs_to :entity, polymorphic: true

  include HasChangelog

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  include HasPrivacy
  scope :is_public, -> { eager_load(:universe).where('universes.privacy = ? OR attributes.privacy = ?', 'public', 'public') }

  after_save do
    if self.attribute_field.field_type == 'universe' && self.value.present?
      entity.update(universe_id: self.value.to_i)
    end
  end
end
