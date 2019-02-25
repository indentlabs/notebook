class AttributeField < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  belongs_to :attribute_category
  has_many :attribute_values, class_name: 'Attribute', dependent: :destroy

  validates_presence_of :user_id

  acts_as_list scope: [:user_id, :attribute_category_id]

  include HasAttributes
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  attr_accessor :system

  before_validation :ensure_name

  def self.color
    'amber'
  end

  def self.icon
    'text_fields'
  end

  # Icon used for a specific attribute field
  def icon
    case self.field_type
    when 'name'
      'fingerprint'
    when 'link'
      'link'
    when 'universe'
      Universe.icon
    when 'textarea'
      'text_fields'
    when 'tags'
      'label'
    else
      'text_fields'
    end
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

  def name_field?
    self.field_type == 'name'
  end

  def universe_field?
    self.field_type == 'universe'
  end

  def tags_field?
    self.field_type == 'tags'
  end

  private

  def ensure_name
    self.name ||= "#{label}-#{Time.now.to_i}".underscore.gsub(' ', '_')
  end
end
