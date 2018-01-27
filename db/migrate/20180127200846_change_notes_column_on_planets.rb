class ChangeNotesColumnOnPlanets < ActiveRecord::Migration
  def change
    remove_column :planets, :public_notes
    add_column :planets, :notes, :string
  end
end
