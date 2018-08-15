class CreateFamousFigureship < ActiveRecord::Migration[4.2]
  def change
    create_table :famous_figureships do |t|
      t.integer :user_id
      t.integer :race_id
      t.integer :famous_figure_id
    end
  end
end
