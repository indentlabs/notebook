class AddSiteAdministratorFlagToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :site_administrator, :boolean, default: false
  end
end
