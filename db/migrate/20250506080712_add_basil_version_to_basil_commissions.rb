class AddBasilVersionToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :basil_version, :integer, default: 1
  end
end
