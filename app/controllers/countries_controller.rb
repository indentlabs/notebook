class CountriesController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :population, :currency, :laws, :sports,
      :area, :crops, :climate,
      :founding_story, :established_year, :notable_wars,
      :notes, :private_notes,
      :privacy
    ]
  end
end
