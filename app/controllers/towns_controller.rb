class TownsController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :laws, :sports, :politics,
      :founding_story, :established_year,
      :notes, :private_notes,
      :privacy
    ]
  end
end
