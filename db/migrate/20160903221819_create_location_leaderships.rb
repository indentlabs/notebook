class CreateLocationLeaderships < ActiveRecord::Migration
  def change
    create_table :location_leaderships do |t|
      t.integer :user_id
      t.integer :location_id
      t.integer :leader_id
    end
  end
end
