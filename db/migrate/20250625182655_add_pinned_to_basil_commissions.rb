class AddPinnedToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :pinned, :boolean, default: false
    add_index :basil_commissions, [:entity_type, :entity_id, :pinned], name: 'index_basil_commissions_on_entity_pinned'
  end
end
