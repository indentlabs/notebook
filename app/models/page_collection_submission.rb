class PageCollectionSubmission < ApplicationRecord
  belongs_to :content, polymorphic: true
  belongs_to :user
end
