class PageField < ActiveRecord::Base
  belongs_to :user
  belongs_to :page_category
  has_many :page_field_values
end
