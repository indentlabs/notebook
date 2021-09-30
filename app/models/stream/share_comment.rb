class ShareComment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  belongs_to :content_page_share

  def from_op?(share)
    user == share.user
  end
end
