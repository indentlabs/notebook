class PageField < ActiveRecord::Base
  belongs_to :user
  belongs_to :page_category
end
