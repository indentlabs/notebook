class AddNotesToFlora < ActiveRecord::Migration[4.2]
  def change
    add_column :floras, :notes, :string
    add_column :floras, :private_notes, :string
  end
end
