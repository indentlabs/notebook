class CreateGovernments < ActiveRecord::Migration
  def change
    create_table :governments do |t|
      t.string :name
      t.string :description
      t.string :type_of_government
      t.string :power_structure
      t.string :power_source
      t.string :checks_and_balances
      t.string :sociopolitical
      t.string :socioeconomical
      t.string :geocultural
      t.string :laws
      t.string :immigration
      t.string :privacy_ideologies
      t.string :electoral_process
      t.string :term_lengths
      t.string :criminal_system
      t.string :approval_ratings
      t.string :military
      t.string :navy
      t.string :airforce
      t.string :space_program
      t.string :international_relations
      t.string :civilian_life
      t.string :founding_story
      t.string :flag_design_story
      t.string :notable_wars
      t.string :notes
      t.string :private_notes
      t.string :privacy
      t.references :user, index: true, foreign_key: true
      t.references :universe, index: true, foreign_key: true
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
