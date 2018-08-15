class CreateGovernmentGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :government_groups do |t|
      t.references :user, index: true, foreign_key: true
      t.references :government, index: true, foreign_key: true
      t.references :group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
