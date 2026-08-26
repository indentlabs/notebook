class AddNotesToBasilCommissions < ActiveRecord::Migration[6.1]
  def change
    add_column :basil_commissions, :notes, :text
  end
end
