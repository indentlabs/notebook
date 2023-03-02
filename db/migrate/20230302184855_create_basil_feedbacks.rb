class CreateBasilFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :basil_feedbacks do |t|
      t.references :basil_commission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score_adjustment, default: 0

      t.timestamps
    end
  end
end
