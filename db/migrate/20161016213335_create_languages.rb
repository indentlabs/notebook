class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name
      t.string :other_names
      t.integer :universe_id
      t.integer :user_id
      t.string :history
      t.string :typology
      t.string :dialectical_information
      t.string :register
      t.string :phonology
      t.string :grammar
      t.string :numbers
      t.string :quantifiers
      t.string :notes
      t.string :private_notes

      t.timestamps null: false
    end
  end
end
