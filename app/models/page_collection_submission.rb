class PageCollectionSubmission < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :page_collection
  belongs_to :user
end
