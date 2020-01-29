
class ContinentsController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :privacy
    ] + [ #<relations>
      custom_attribute_values:            [:name, :value],
      continent_landmarks_attributes:     [:id, :landmark_id, :_destroy],
      continent_creatures_attributes:     [:id, :creature_id, :_destroy],
      continent_floras_attributes:        [:id, :flora_id, :_destroy],
      continent_countries_attributes:     [:id, :country_id, :_destroy],
      continent_languages_attributes:     [:id, :language_id, :_destroy],
      continent_traditions_attributes:    [:id, :tradition_id, :_destroy],
      continent_governments_attributes:   [:id, :government_id, :_destroy],
      continent_popular_foods_attributes: [:id, :popular_food_id, :_destroy],
    ]
  end
end
    