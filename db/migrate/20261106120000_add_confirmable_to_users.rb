# Columns for Devise's :confirmable module. Nullable with no default, so Postgres only touches the
# catalog and doesn't rewrite the table, but it still needs a brief exclusive lock on a table that
# every signed-in request writes to. Give up quickly rather than queueing everything behind us.
class AddConfirmableToUsers < ActiveRecord::Migration[6.1]
  def up
    set_lock_timeout
    add_column :users, :confirmation_token,   :string
    add_column :users, :confirmed_at,         :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email,    :string
  end

  def down
    set_lock_timeout
    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end

  private

  def set_lock_timeout
    execute "SET LOCAL lock_timeout = '5s'" if connection.adapter_name == 'PostgreSQL'
  end
end
