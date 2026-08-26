class AddArchivedToWritingGoals < ActiveRecord::Migration[6.1]
  def change
    add_column :writing_goals, :archived, :boolean, default: false, null: false
  end
end
