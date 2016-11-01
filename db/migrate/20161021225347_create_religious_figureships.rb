class CreateReligiousFigureships < ActiveRecord::Migration
  def change
    create_table :religious_figureships do |t|
      t.integer :religion_id
      t.integer :user_id
      t.integer :notable_figure_id
    end
  end
end
