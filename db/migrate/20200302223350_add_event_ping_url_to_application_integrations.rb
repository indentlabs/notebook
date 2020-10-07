class AddEventPingUrlToApplicationIntegrations < ActiveRecord::Migration[6.0]
  def change
    add_column :application_integrations, :event_ping_url, :string
  end
end
