# Controller for the Language model
class LanguagesController < ContentController
  private

  def content_params
    params.require(:language).permit(
      :user_id, :universe_id,
      :name,
      :words,
      :established_year, :established_location,
      :characters, :locations,
      :notes)
  end
end
