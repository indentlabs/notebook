class ChangeNotesColumnOnPlanets < ActiveRecord::Migration[4.2]
  def change
    remove_column :planets, :public_notes
    add_column :planets, :notes, :string
  end
end
