class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.references :universe, index: true, foreign_key: true
      t.string :email
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
