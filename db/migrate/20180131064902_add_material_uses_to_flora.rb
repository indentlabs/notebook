class AddMaterialUsesToFlora < ActiveRecord::Migration[4.2]
  def change
    add_column :floras, :material_uses, :string
  end
end
