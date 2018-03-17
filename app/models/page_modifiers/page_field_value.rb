#<PageFieldValue
#  id: nil,
#  page_field_id: nil,
#  page_id: nil, #todo placeholder for per-page attributes
#  value: nil,
#  user_id: nil,
#  created_at: nil,
#  updated_at: nil>
class PageFieldValue < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :page_field
  belongs_to :user
end
