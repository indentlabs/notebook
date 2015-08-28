# Controller for the Language model
class LanguagesController < ApplicationController
  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]

  before_action :require_ownership, only: [:update, :edit, :destroy]

  before_action :hide_private_language, only: [:show]

  def index
    @languages = Language.where(user_id: session[:user])
                 .order(:name).presence || []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @languages }
    end
  end

  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @language }
    end
  end

  def new
    @language = Language.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @language }
    end
  end

  def edit
    @language = Language.find(params[:id])
  end

  def create
    @language = create_language_from_params

    # rubocop:disable LineLength
    respond_to do |format|
      if @language.save
        notice = t :create_success, model_name: Language.model_name.human
        format.html { redirect_to @language, notice: notice }
        format.json { render json: @language, status: :created, location: @language }
      else
        format.html { render action: 'new' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
    # rubocop:enable LineLength
  end

  def update
    @language = update_language_from_params

    respond_to do |format|
      if @language.update_attributes(language_params)
        notice = t :update_success, model_name: Language.model_name.human
        format.html { redirect_to @language, notice: notice }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @language = Language.find(params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to language_list_url }
      format.json { head :no_content }
    end
  end

  private

  def language_params
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
