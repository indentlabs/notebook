class AddOct19Migrations < ActiveRecord::Migration[6.0]
  def change
    add_index(:attribute_fields, [:deleted_at, :position])
  end
end
