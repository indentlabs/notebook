class AddApplicationTokenToApplicationIntegrations < ActiveRecord::Migration[6.0]
  def change
    add_column :application_integrations, :application_token, :string
  end
end
