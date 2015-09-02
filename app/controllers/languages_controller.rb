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

  def update_language_from_params
    params[:language][:universe] = universe_from_language_params
    Language.find(params[:id])
  end

  def create_language_from_params
    language = Language.create(language_params)
    language.user_id = session[:user]
    language.universe = universe_from_language_params
    language
  end

  def universe_from_language_params
    Universe.where(user_id: session[:user],
                   name: params[:language][:universe].strip).first.presence
  end
end
