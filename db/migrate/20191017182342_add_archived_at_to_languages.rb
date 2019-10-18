class AddArchivedAtToLanguages < ActiveRecord::Migration[5.2]
  def change
    add_column :languages, :archived_at, :datetime
  end
end
