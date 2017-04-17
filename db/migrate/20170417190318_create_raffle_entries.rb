class CreateRaffleEntries < ActiveRecord::Migration
  def change
    create_table :raffle_entries do |t|
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
