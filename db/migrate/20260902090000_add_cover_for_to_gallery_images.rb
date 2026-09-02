# Per-shape cover choice. An image can be the cover for specific display
# shapes (ImagePresets keys, e.g. ["banner"]) while `pinned` remains the
# cover for every shape that has no specific choice.
class AddCoverForToGalleryImages < ActiveRecord::Migration[6.1]
  def change
    %i[image_uploads basil_commissions].each do |table|
      add_column table, :cover_for, :json
    end
  end
end
