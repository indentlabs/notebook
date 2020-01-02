class AddOccupationToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :occupation, :string
  end
end
