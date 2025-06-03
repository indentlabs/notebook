class ChangeDefaultBasilVersionInBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    change_column_default :basil_commissions, :basil_version, from: 1, to: 2
  end
end
