class CreateApplicationIntegrations < ActiveRecord::Migration[6.0]
  def change
    create_table :application_integrations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.string :organization_name
      t.string :organization_url
      t.string :website_url
      t.string :privacy_policy_url
      t.string :token
      t.datetime :last_used_at
      t.string :authorization_callback_url

      t.timestamps
    end
  end
end
