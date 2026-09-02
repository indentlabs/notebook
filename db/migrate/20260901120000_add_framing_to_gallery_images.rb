# Per-image framing for the gallery editor.
#
# crops  - normalised crop rectangles per display shape (see ImagePresets):
#            { "banner" => { "x" => 0.1, "y" => 0.0, "w" => 0.8, "h" => 0.4 }, ... }
#          Coordinates are fractions (0..1) of the original image, so they
#          survive any re-encode or resize.
# focal  - the point (fractions of width/height) that should stay visible
#          when a shape without its own crop is rendered with object-fit.
# width/height - pixel dimensions of the original, captured on upload.
# crops_generated_at - when derivative files were last produced for the
#          current crops (nil until the job has run).
class AddFramingToGalleryImages < ActiveRecord::Migration[6.1]
  def change
    %i[image_uploads basil_commissions].each do |table|
      add_column table, :crops, :json, default: {}
      add_column table, :focal_x, :float, default: 0.5, null: false
      add_column table, :focal_y, :float, default: 0.5, null: false
      add_column table, :width, :integer
      add_column table, :height, :integer
      add_column table, :crops_generated_at, :datetime
    end
  end
end
