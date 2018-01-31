class AddMaterialUsesToFlora < ActiveRecord::Migration
  def change
    add_column :floras, :material_uses, :string
  end
end
