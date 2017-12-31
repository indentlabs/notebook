class LandmarksController < ContentController
  private

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :description, :other_names,
      :size, :materials, :colors,
      :creation_story, :established_year,
      :notes, :private_notes,
      :privacy
    ]
  end
end
