class AddRoleToContributors < ActiveRecord::Migration[6.1]
  def up
    add_column :contributors, :role, :string, default: 'full', null: false

    # All existing contributors already function as full contributors, so label them as such
    execute "UPDATE contributors SET role = 'full' WHERE role IS NULL"
  end

  def down
    remove_column :contributors, :role
  end
end
