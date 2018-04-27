#<PageCategory
#  id: nil,
#  label: nil,
#  universe_id: nil,
#  content_type: nil,
#  icon: nil,
#  created_at: nil,
#  updated_at: nil>
class PageCategory < ActiveRecord::Base
  belongs_to :universe

  # Until we fully migrate over, we want to make sure these mirrored categories
  # are linked to their owner, so we can create them a universe for them at
  # migration time. This column can be removed after the migration to attr-v2.
  belongs_to :user

  has_many :page_fields, dependent: :destroy

  validates_presence_of :content_type, :label

  def name
    self.label.downcase.gsub(' ', '_')
  end
end
