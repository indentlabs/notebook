class DropNotNullConstraintFromBasilCommissions < ActiveRecord::Migration[6.1]
  def up
    change_column_null :basil_commissions, :user_id, true
    change_column_null :basil_commissions, :entity_type, true
    change_column_null :basil_commissions, :entity_id, true
  end

  def down
    change_column_null :basil_commissions, :user_id, false
    change_column_null :basil_commissions, :entity_type, false
    change_column_null :basil_commissions, :entity_id, false
  end
end
