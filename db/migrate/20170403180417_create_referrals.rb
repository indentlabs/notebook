class CreateReferrals < ActiveRecord::Migration[4.2]
  def change
    create_table :referrals do |t|
      t.integer :referrer_id
      t.integer :referred_id
      t.integer :associated_code_id

      t.timestamps null: false
    end
  end
end
