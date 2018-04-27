#<PageField
#  id: nil,
#  label: nil,
#  page_category_id: nil,
#  field_type: "textarea",
#  created_at: nil,
#  updated_at: nil>
class PageField < ActiveRecord::Base
  belongs_to :user
  belongs_to :page_category

  has_many :page_field_values, dependent: :destroy

  delegate :content_type, to: :page_category

  def name
    self.label.downcase.gsub(' ', '_')
  end
end
