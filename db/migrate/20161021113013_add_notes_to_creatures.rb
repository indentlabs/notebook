class AddNotesToCreatures < ActiveRecord::Migration[4.2]
  def change
    add_column :creatures, :notes, :string
    add_column :creatures, :private_notes, :string
  end
end
