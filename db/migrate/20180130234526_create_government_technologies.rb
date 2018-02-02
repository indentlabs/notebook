class CreateGovernmentTechnologies < ActiveRecord::Migration
  def change
    create_table :government_technologies do |t|
      t.references :user, index: true, foreign_key: true
      t.references :government, index: true, foreign_key: true
      t.references :technology, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
