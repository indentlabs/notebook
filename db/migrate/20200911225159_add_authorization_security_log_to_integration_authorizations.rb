class AddAuthorizationSecurityLogToIntegrationAuthorizations < ActiveRecord::Migration[6.0]
  def change
    add_column :integration_authorizations, :origin, :string
    add_column :integration_authorizations, :content_type, :string
    add_column :integration_authorizations, :user_agent, :string
  end
end
