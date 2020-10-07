class AddUserTokenToIntegrationAuthorizations < ActiveRecord::Migration[6.0]
  def change
    add_column :integration_authorizations, :user_token, :string
  end
end
