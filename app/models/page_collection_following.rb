class PageCollectionFollowing < ApplicationRecord
  belongs_to :page_collection
  belongs_to :user
end
