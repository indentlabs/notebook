class AttributeField < ActiveRecord::Base
  belongs_to :user

  include HasAttributes
  include Serendipitous::Concern

  attr_accessor :system

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

  def name
    (self['name'] || "custom field #{Time.now.to_i}").downcase.gsub(' ','_')
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
end
