class DisableModerationOnForums < ActiveRecord::Migration[5.2]
  def change
    change_column_default :thredded_user_details, :moderation_state, 1 # approved
  end
end
