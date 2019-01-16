class AttributeCategory < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  has_many   :attribute_fields, dependent: :destroy

  include HasAttributes
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  acts_as_list scope: [:user_id, :entity_type]

  before_validation :ensure_name

  def self.color
    'amber'
  end

  def icon
    icon_override || self.class.icon
  end

  def self.icon
    'folder_open'
  end

  def self.content_name
    'attribute_category'
  end

  def icon
    self['icon'] || self.class.icon
  end

  def entity_class
    entity_type.titleize.constantize
  end

  private

  def ensure_name
    self.name ||= "#{label}-#{Time.now.to_i}".underscore.gsub(' ', '_')
  end
end
