class AddStyleToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :style, :string
  end
end
