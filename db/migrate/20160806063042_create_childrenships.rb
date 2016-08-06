class CreateChildrenships < ActiveRecord::Migration
  def change
    create_table :childrenships do |t|
      t.references :user, index: true
      t.references :character, index: true
      t.references :child, index: true
    end
    add_foreign_key :childrenships, :users
    add_foreign_key :childrenships, :characters
    add_foreign_key :childrenships, :children
  end
end
