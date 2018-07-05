class CreateVotables < ActiveRecord::Migration[4.2]
  def change
    create_table :votables do |t|
      t.string :name
      t.string :description
      t.string :icon
      t.string :link

      t.timestamps null: false
    end
  end
end
