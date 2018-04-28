#<Attribute
#  id: nil,
#  user_id: nil,
#  attribute_field_id: nil,
#  entity_type: nil,
#  entity_id: nil,
#  value: nil,
#  privacy: "private",
#  created_at: nil,
#  updated_at: nil>
class Attribute < ActiveRecord::Base
  belongs_to :user
  belongs_to :attribute_field
  belongs_to :entity, polymorphic: true

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  include HasPrivacy
  scope :is_public, -> { eager_load(:universe).where('universes.privacy = ? OR attributes.privacy = ?', 'public', 'public') }

  after_create do
    # Create a mirrored PageFieldValue
    PageFieldValue.create(
      page_field: self.attribute_field.mirrored_page_field,
      value: self.value,
      user: self.user
    )
  end

  after_update do
    # Since we're just immediately swapping over to pagefieldvalues there's no need to do this mirroring anymore
    #TODO remove this entire class once we're live
    #mirrored_page_field_value.update(value: self.value)
  end

  after_destroy do
    # Destroy the mirrored PageFieldValue
    value = mirrored_page_field_value
    value.destroy if value
  end

  def mirrored_page_field_value
    PageFieldValue.find_by(
      page_field: self.attribute_field.mirrored_page_field,
      user: self.user
    )
  end
end
