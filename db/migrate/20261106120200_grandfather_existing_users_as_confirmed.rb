# Accounts that existed before email confirmation was turned on keep everything they could already
# do: mark them all confirmed as of the day they signed up. Only accounts made from here on have to
# confirm their address before posting on the forums or making things public.
#
# Updated in batches so no single statement holds row locks on the whole users table, which
# sign-ins and other requests write to constantly.
class GrandfatherExistingUsersAsConfirmed < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # Plain model, so soft-deleted accounts are included and no User callbacks or validations run
  class User < ActiveRecord::Base
    self.table_name = 'users'
  end

  BATCH_SIZE = 10_000

  def up
    User.where(confirmed_at: nil).in_batches(of: BATCH_SIZE) do |batch|
      batch.update_all('confirmed_at = COALESCE(created_at, CURRENT_TIMESTAMP)')
    end
  end

  def down
    # Nothing to undo: rolling back AddConfirmableToUsers drops the column.
  end
end
