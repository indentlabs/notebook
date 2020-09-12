class CreateApiRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :api_requests do |t|
      t.references :application_integration, null: true, foreign_key: true
      t.references :integration_authorization, null: true, foreign_key: true
      t.string :result
      t.integer :updates_used, default: 0
      t.string :ip_address

      t.timestamps
    end
  end
end
