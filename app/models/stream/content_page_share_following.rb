class ContentPageShareFollowing < ApplicationRecord
  belongs_to :content_page_share
  belongs_to :user
end
