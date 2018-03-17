#<PageFieldValue
#  id: nil,
#  page_field_id: nil,
#  page_id: nil, #todo this might not be needed
#  value: nil,
#  user_id: nil,
#  created_at: nil,
#  updated_at: nil>
class PageFieldValue < ActiveRecord::Base
  belongs_to :page_field
  belongs_to :user
end
