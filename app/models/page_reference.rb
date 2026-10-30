class PageReference < ApplicationRecord
  belongs_to :referencing_page, polymorphic: true
  belongs_to :referenced_page, polymorphic: true
  belongs_to :attribute_field

  # Listing a reference names the page it came from, so only list ones the viewer can read
  def self.visible_to(viewer)
    preload(:referencing_page).select { |reference| reference.referencing_page&.readable_by?(viewer) }
  end
end
