class PageCollection < ApplicationRecord
  belongs_to :user

  serialize :page_types, Array

  def self.color
    'brown'
  end

  def self.icon
    'layers'
  end
end
