class CharactersController < ApplicationController
  before_filter :create_anonymous_account_if_not_logged_in, :only => [:edit, :create, :update]
  before_filter :require_ownership_of_character, :only => [:update, :edit, :destroy]
  before_filter :hide_private_character, :only => [:show]

  # GET /characters
  # GET /characters.json
  def index
    @characters = Character.where(user_id: session[:user])
    
    if @characters.length == 0
      @characters = []
    end
    
    if params[:universe]
      @universe = Universe.where(user_id: session[:user]).where(name: params[:universe].strip).first
      @characters = @characters.where(universe_id: @universe.id) if @characters.length > 0
      @selected_universe_filter = @universe.name  	
    end

    @characters = @characters.sort { |a, b| a.name.downcase <=> b.name.downcase }

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
    @character = Character.create(params.require(:character).permit(:name, :age, :universe_id))
    @character.user_id = session[:user]
    @character.universe = Universe.where(user_id: session[:user]).where(name: params[:character][:universe].strip).first

    respond_to do |format|
      if @character.save
        format.html { redirect_to @character, notice: 'Character was successfully created.' }
        format.json { render json: @character, status: :created, location: @character }
      else
        format.html { render action: "new" }
        format.json { render json: @character.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /characters/1
  # PUT /characters/1.json
  def update
    @character = Character.find(params[:id])
    
    if params[:character][:universe].empty?
      params[:character][:universe] = nil
    else
      params[:character][:universe] = Universe.where(user_id: session[:user]).where(name: params[:character][:universe].strip).first
    end

    respond_to do |format|
      if @character.update_attributes(params[:character])
        format.html { redirect_to @character, notice: 'Character was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @character.errors, status: :unprocessable_entity }
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
end
