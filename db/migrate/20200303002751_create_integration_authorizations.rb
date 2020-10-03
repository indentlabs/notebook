class CreateIntegrationAuthorizations < ActiveRecord::Migration[6.0]
  def change
    create_table :integration_authorizations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :application_integration, null: false, foreign_key: true
      t.string :referral_url
      t.string :ip_address

      t.timestamps
    end
  end
end
