class AddFavoriteDefaults < ActiveRecord::Migration[6.0]
  def change
    # Generated with
    # Rails.application.config.content_types[:all].each do |content_type|
    #   puts "change_column_default :#{content_type.name.downcase.pluralize}, :favorite, false"
    # end
    change_column_default :universes, :favorite, false
    change_column_default :characters, :favorite, false
    change_column_default :locations, :favorite, false
    change_column_default :items, :favorite, false
    change_column_default :buildings, :favorite, false
    change_column_default :conditions, :favorite, false
    change_column_default :continents, :favorite, false
    change_column_default :countries, :favorite, false
    change_column_default :creatures, :favorite, false
    change_column_default :deities, :favorite, false
    change_column_default :floras, :favorite, false
    change_column_default :foods, :favorite, false
    change_column_default :governments, :favorite, false
    change_column_default :groups, :favorite, false
    change_column_default :jobs, :favorite, false
    change_column_default :landmarks, :favorite, false
    change_column_default :languages, :favorite, false
    change_column_default :lores, :favorite, false
    change_column_default :magics, :favorite, false
    change_column_default :planets, :favorite, false
    change_column_default :races, :favorite, false
    change_column_default :religions, :favorite, false
    change_column_default :scenes, :favorite, false
    change_column_default :schools, :favorite, false
    change_column_default :sports, :favorite, false
    change_column_default :technologies, :favorite, false
    change_column_default :towns, :favorite, false
    change_column_default :traditions, :favorite, false
    change_column_default :vehicles, :favorite, false
    change_column_default :documents, :favorite, false
    change_column_default :timelines, :favorite, false
  end
end
