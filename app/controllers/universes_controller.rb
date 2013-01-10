class UniversesController < ApplicationController
  before_filter :redirect_if_not_logged_in
  before_filter :require_ownership_of_universe, :only => [:show, :edit, :destroy]

  def index
  	@universes = Universe.where(user_id: session[:user])
    
    if @universes.size == 0
      @universes = []
    end
    
		@universes = @universes.sort { |a, b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @universes }
    end
  end

  def show
    @universe = Universe.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @universe }
    end
  end

  def new
    @universe = Universe.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @universe }
    end
  end

  def edit
    @universe = Universe.find(params[:id])
  end

  def create
    @universe = Universe.new(params[:universe])
    @universe.user_id = session[:user]

    respond_to do |format|
      if @universe.save
        format.html { redirect_to @universe, notice: 'Universe was successfully created.' }
        format.json { render json: @universe, status: :created, location: @universe }
      else
        format.html { render action: "new" }
        format.json { render json: @universe.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @universe = Universe.find(params[:id])

    respond_to do |format|
      if @universe.update_attributes(params[:universe])
        format.html { redirect_to @universe, notice: 'Universe was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @universe.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @universe = Universe.find(params[:id])
    @universe.destroy

    respond_to do |format|
      format.html { redirect_to universe_list_url }
      format.json { head :no_content }
    end
  end
end
