# Controller for the Character model
class CharactersController < ApplicationController
  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]
  before_action :require_ownership_of_character,
                only: [:update, :edit, :destroy]
  before_action :hide_private_character, only: [:show]

  # GET /characters
  # GET /characters.json
  def index
    @characters = Character.where(user_id: session[:user]).presence || []
    populate_universe_fields if params[:universe]
    @characters.sort!

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @characters }
    end
  end

  # GET /characters/1
  # GET /characters/1.json
  def show
    @character = Character.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @character }
    end
  end

  # GET /characters/new
  # GET /characters/new.json
  def new
    @character = Character.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @character }
    end
  end

  # GET /characters/1/edit
  def edit
    @character = Character.find(params[:id])
  end

  # POST /characters
  # POST /characters.json
  def create
    @character = create_character_from_params

    # rubocop:disable LineLength
    respond_to do |format|
      if @character.save
        format.html { render_html_success t(:character_create_success) }
        format.json { render json: @character, status: :created, location: @character }
      else
        format.html { render action: 'new' }
        format.json { render_json_error_unprocessable }
      end
    end
    # rubocop:enable LineLength
  end

  # PUT /characters/1
  # PUT /characters/1.json
  def update
    @character = update_character_from_params

    respond_to do |format|
      if @character.update_attributes(character_params)
        format.html { render_html_success t(:character_update_success) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render_json_error_unprocessable }
      end
    end
  end

  # DELETE /characters/1
  # DELETE /characters/1.json
  def destroy
    Character.find(params[:id]).delete

    respond_to do |format|
      format.html { redirect_to character_list_url }
      format.json { head :no_content }
    end
  end

  private

  def character_params
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
    @characters =
      @characters.where(universe_id: @universe.id) if @characters.blank?
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
