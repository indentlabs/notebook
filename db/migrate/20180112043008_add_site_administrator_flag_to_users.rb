class AddSiteAdministratorFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :site_administrator, :boolean, default: false
  end
end
