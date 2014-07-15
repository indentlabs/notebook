class LanguagesController < ApplicationController
  before_filter :create_anonymous_account_if_not_logged_in, :only => [:edit, :create, :update]
  before_filter :require_ownership_of_language, :only => [:update, :edit, :destroy]
  before_filter :hide_private_language, :only => [:show]

  def index
  	@languages = Language.where(user_id: session[:user])
    
    if @languages.size == 0
      @languages = []
    end
    
		@languages = @languages.sort { |a, b| a.name.downcase <=> b.name.downcase }

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
    @language = Language.new(language_params)
    @language.user_id = session[:user]
    @language.universe = Universe.where(user_id: session[:user]).where(name: params[:language][:universe].strip).first

    respond_to do |format|
      if @language.save
        format.html { redirect_to @language, notice: 'Language was successfully created.' }
        format.json { render json: @language, status: :created, location: @language }
      else
        format.html { render action: "new" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @language = Language.find(params[:id])
    if params[:language][:universe].empty?
      params[:language][:universe] = nil
    else
      params[:language][:universe] = Universe.where(user_id: session[:user]).where(name: params[:language][:universe].strip).first
    end

    respond_to do |format|
      if @language.update_attributes(language_params)
        format.html { redirect_to @language, notice: 'Language was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @language.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @language = Language.find(params[:id])
    @language.destroy

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
        
end
