class ShareComment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :content_page_share

  def from_op?(share)
    user == share.user
  end
end
