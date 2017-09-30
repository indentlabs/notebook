class CreateFloraMagicalEffects < ActiveRecord::Migration
  def change
    create_table :flora_magical_effects do |t|
      t.integer :flora_id
      t.integer :magic_id

      t.timestamps null: false
    end
  end
end
