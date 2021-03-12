class AddMoreIndexesMarch82021 < ActiveRecord::Migration[6.0]
  def change
    add_index :contributors, [:email, :user_id]
  end
end
