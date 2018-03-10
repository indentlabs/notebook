class PageCategory < ActiveRecord::Base
  belongs_to :universe
  has_many :page_fields, dependent: :destroy

  validates_presence_of :content_type, :label
end
