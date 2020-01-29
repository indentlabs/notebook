class CreateContinentGovernments < ActiveRecord::Migration[6.0]
  def change
    create_table :continent_governments do |t|
      t.references :continent, null: false, foreign_key: true
      t.references :government, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
