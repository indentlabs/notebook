#<AttributeField
#  id: nil,
#  user_id: nil,
#  attribute_category_id: nil,
#  name: nil,
#  label: nil,
#  field_type: nil,
#  description: nil,
#  privacy: "private",
#  created_at: nil,
#  updated_at: nil>
class AttributeField < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  belongs_to :attribute_category
  has_many :attribute_values, class_name: 'Attribute'

  include HasAttributes
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  attr_accessor :system

  after_create do
    # Create a mirrored PageField
    PageField.create(
      label: self.label,
      page_category: self.attribute_category.mirrored_page_category,
      field_type: 'textarea'
    )
  end

  after_destroy do
    # Destroy the mirrored PageField
    field = mirrored_page_field
    field.destroy if field
  end

  def mirrored_page_field
    PageField.find_by(
      label: self.label,
      page_category: self.attribute_category.mirrored_page_category,
      field_type: 'textarea'
    )
  end

  before_validation :ensure_name

  scope :is_public, -> { eager_load(:universe).where('universes.privacy = ? OR attribute_fields.privacy = ?', 'public', 'public') }

  def self.color
    'amber'
  end

  def self.icon
    'text_fields'
  end

  def self.content_name
    'attribute'
  end

  def humanize
    label
  end

  def private?
    privacy != 'public'
  end

  def system?
    !!self.system
  end

  private

  def ensure_name
    self.name ||= "#{label}-#{Time.now.to_i}".underscore.gsub(' ', '_')
  end
end
