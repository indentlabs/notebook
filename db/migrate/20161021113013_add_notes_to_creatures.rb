class AddNotesToCreatures < ActiveRecord::Migration
  def change
    add_column :creatures, :notes, :string
    add_column :creatures, :private_notes, :string
  end
end
