class CreateGovernmentPoliticalFigures < ActiveRecord::Migration
  def change
    create_table :government_political_figures do |t|
      t.references :user, index: true, foreign_key: true
      t.references :government, index: true, foreign_key: true
      t.integer :political_figure_id

      t.timestamps null: false
    end
  end
end
