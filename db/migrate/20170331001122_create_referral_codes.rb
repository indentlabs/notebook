class CreateReferralCodes < ActiveRecord::Migration
  def change
    create_table :referral_codes do |t|
      t.references :user, index: true, foreign_key: true
      t.string :code

      t.timestamps null: false
    end
  end
end
