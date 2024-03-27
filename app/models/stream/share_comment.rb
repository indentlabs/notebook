class ShareComment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, optional: true # now that we're auto-deleting this data, we can probably remove this constraint without db errors
  belongs_to :content_page_share

  def from_op?(share)
    user == share.user
  end
end
