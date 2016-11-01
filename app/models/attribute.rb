class Attribute < ActiveRecord::Base
  belongs_to :user
  belongs_to :attribute_field
  belongs_to :entity, polymorphic: true

  include HasPrivacy
  scope :is_public, -> { eager_load(:universe).where('universes.privacy = ? OR attributes.privacy = ?', 'public', 'public') }
end
