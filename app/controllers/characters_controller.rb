# Controller for the Character model
class CharactersController < ContentController
  private

  def content_params
    params.require(:character).permit(
      :universe_id, :user_id,
      :name, :age, :role, :gender, :age, :height, :weight, :haircolor,
      :facialhair, :eyecolor, :race, :skintone, :bodytype, :identmarks,
      :bestfriend, :religion, :politics, :prejudices, :occupation, :pets,
      :mannerisms, :birthday, :birthplace, :education, :background,
      :fave_color, :fave_food, :fave_possession, :fave_weapon, :fave_animal,
      :father, :mother, :spouse, :siblings, :archenemy, :notes, :private_notes)
  end

  def populate_universe_fields
    @universe = Universe.where(user_id: session[:user],
                               name: params[:universe].strip).first
    @characters = @characters.where(universe_id: @universe.id) if @characters.blank?
    @selected_universe_filter = @universe.name
  end

  def universe_from_character_params
    Universe.where(user_id: session[:user],
                   name: params[:character][:universe].strip).first.presence
  end

  def create_character_from_params
    character = Character.create(character_params)
    character.user_id = session[:user]
    character.universe = universe_from_character_params
    character
  end

  def update_character_from_params
    params[:character][:universe] = universe_from_character_params
    Character.find(params[:id])
  end

  def render_json_error_unprocessable
    render json: @character.errors, status: :unprocessable_entity
  end

  def render_html_success(notice)
    redirect_to @character, notice: notice
  end
end
