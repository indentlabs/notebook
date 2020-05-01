class PageCollection < ApplicationRecord
  belongs_to :user

  serialize :page_types, Array
end
