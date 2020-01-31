class ChangeUniverseNullableOnCountries < ActiveRecord::Migration[6.0]
  def change
    change_column_null :continents, :universe_id, true
  end
end
