class AddBasilCommissionIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :basil_commissions, :job_id
    add_index :basil_commissions, [:entity_type, :entity_id], name: 'basil_commissions_ee'
    add_index :basil_commissions, [:entity_type, :entity_id, :saved_at], name: 'basil_commissions_ees'
    add_index :basil_commissions, [:entity_type, :entity_id, :style], name: 'basil_commissions_ees2'
    add_index :basil_commissions, [:user_id, :entity_type, :entity_id], name: 'basil_commissions_uee'
    add_index :basil_commissions, [:user_id, :entity_type, :entity_id, :saved_at], name: 'basil_commissions_uees'
    add_index :basil_commissions, [:user_id, :entity_type, :entity_id, :style], name: 'basil_commissions_uees2'
  end
end
