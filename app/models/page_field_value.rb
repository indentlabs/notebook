class PageFieldValue < ActiveRecord::Base
  belongs_to :page_field
  belongs_to :user
end
