class AttributeCategory < ActiveRecord::Base
  belongs_to :user
  has_many   :attribute_fields

  include HasAttributes
  include Serendipitous::Concern

  def self.color
    'amber'
  end

  def self.icon
    'chrome_reader_mode'
  end

  def self.content_name
    'attribute_category'
  end
end
