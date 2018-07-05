class AddFieldsToTown < ActiveRecord::Migration[4.2]
  def change
    add_reference :towns, :universe, index: true, foreign_key: true
    add_column :towns, :deleted_at, :datetime
  end
end
