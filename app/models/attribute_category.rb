class AttributeCategory < ActiveRecord::Base
  belongs_to :user
  has_many   :attribute_fields

  include Serendipitous::Concern

  def self.color
    'amber'
  end

  def self.icon
    'chrome_reader_mode'
  end

  def self.content_name
    'attribute category'
  end

  def self.attribute_categories
    {
      general: {
        icon: 'info',
        attributes: %w(name label icon entity_type)
      }
    }
  end
end
