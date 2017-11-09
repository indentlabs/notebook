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
