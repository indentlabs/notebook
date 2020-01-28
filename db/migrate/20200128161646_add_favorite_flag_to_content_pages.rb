class AddFavoriteFlagToContentPages < ActiveRecord::Migration[6.0]
  def change
    add_column :universes, :favorite, :boolean
    add_column :characters, :favorite, :boolean
    add_column :locations, :favorite, :boolean
    add_column :items, :favorite, :boolean
    add_column :buildings, :favorite, :boolean
    add_column :conditions, :favorite, :boolean
    add_column :countries, :favorite, :boolean
    add_column :creatures, :favorite, :boolean
    add_column :deities, :favorite, :boolean
    add_column :floras, :favorite, :boolean
    add_column :foods, :favorite, :boolean
    add_column :governments, :favorite, :boolean
    add_column :groups, :favorite, :boolean
    add_column :jobs, :favorite, :boolean
    add_column :landmarks, :favorite, :boolean
    add_column :languages, :favorite, :boolean
    add_column :magics, :favorite, :boolean
    add_column :planets, :favorite, :boolean
    add_column :races, :favorite, :boolean
    add_column :religions, :favorite, :boolean
    add_column :scenes, :favorite, :boolean
    add_column :schools, :favorite, :boolean
    add_column :sports, :favorite, :boolean
    add_column :technologies, :favorite, :boolean
    add_column :towns, :favorite, :boolean
    add_column :traditions, :favorite, :boolean
    add_column :vehicles, :favorite, :boolean
  end
end
