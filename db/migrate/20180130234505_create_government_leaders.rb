class CreateGovernmentLeaders < ActiveRecord::Migration[4.2]
  def change
    create_table :government_leaders do |t|
      t.references :user, index: true, foreign_key: true
      t.references :government, index: true, foreign_key: true
      t.integer :leader_id

      t.timestamps null: false
    end
  end
end
