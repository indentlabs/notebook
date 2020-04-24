class ContentPageShare < ApplicationRecord
  belongs_to :user
  belongs_to :content_page, polymorphic: true
end
