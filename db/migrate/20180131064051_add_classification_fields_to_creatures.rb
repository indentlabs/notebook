class AddClassificationFieldsToCreatures < ActiveRecord::Migration
  def change
    add_column :creatures, :phylum, :string
    add_column :creatures, :class_string, :string
    add_column :creatures, :order, :string
    add_column :creatures, :family, :string
    add_column :creatures, :genus, :string
    add_column :creatures, :species, :string
  end
end
