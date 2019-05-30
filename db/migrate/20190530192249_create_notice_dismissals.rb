class CreateNoticeDismissals < ActiveRecord::Migration[5.2]
  def change
    create_table :notice_dismissals do |t|
      t.references :user, foreign_key: true
      t.integer :notice_id

      t.timestamps
    end
  end
end
