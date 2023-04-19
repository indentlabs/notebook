class AddDeletedAtColumnToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :deleted_at, :datetime
  end
end
