class ChangeNullableOnContinentLinkModels < ActiveRecord::Migration[6.0]
  def change
    change_column_null :continent_countries, :user_id, true
    change_column_null :continent_creatures, :user_id, true
    change_column_null :continent_floras, :user_id, true
    change_column_null :continent_governments, :user_id, true
    change_column_null :continent_landmarks, :user_id, true
    change_column_null :continent_languages, :user_id, true
    change_column_null :continent_popular_foods, :user_id, true
    change_column_null :continent_traditions, :user_id, true

    change_column_null :planet_continents, :user_id, true

    change_column_null :country_bordering_countries, :user_id, true
  end
end
