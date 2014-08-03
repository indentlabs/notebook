class LocationsController < ApplicationController
  before_filter :create_anonymous_account_if_not_logged_in, :only => [:edit, :create, :update]
  before_filter :require_ownership_of_location, :only => [:update, :edit, :destroy]
  before_filter :hide_private_location, :only => [:show]

  def index
    @locations = Location.where(user_id: session[:user])
    
    if @locations.size == 0
      @locations = []
    end
    
    @locations = @locations.sort { |a, b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @locations }
    end
  end

  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location }
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def create
    @location = Location.new(location_params)
    @location.user_id = session[:user]
    @location.universe = Universe.where(user_id: session[:user]).where(name: params[:location][:universe].strip).first

    notice = ''

    respond_to do |format|
      begin
        if @location.save
          if notice == ''
            notice = 'Location was successfully created.'
          end

          format.html { redirect_to @location, notice: notice }
          format.json { render json: @location, status: :created, location: @location }
        else
          format.html { render action: "new" }
          format.json { render json: @location.errors, status: :unprocessable_entity }
        end
      rescue Errno::ECONNRESET
        # Connection was reset, probably because of the file upload. Try again without it.
        @location.map = nil
        notice = 'Location was created, but your map did not upload. Please try again.'
        retry
      end
    end
  end

  def update
    @location = Location.find(params[:id])

    if params[:location][:universe].empty?
      params[:location][:universe] = nil
    else
      params[:location][:universe] = Universe.where(user_id: session[:user]).where(name: params[:location][:universe].strip).first
    end

    respond_to do |format|
      begin
        if @location.update_attributes(location_params)
          format.html { redirect_to @location, notice: 'Location was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @location.errors, status: :unprocessable_entity }
        end
      rescue Errno::ECONNRESET
        # Connection was reset, probably because of the file upload. Try again without it.
        @location.map = nil
        notice = 'Location was created, but your map did not upload. Please try again.'
        retry
      end
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to location_list_url }
      format.json { head :no_content }
    end
  end
  
  private
    def location_params
      params.require(:location).permit(
        :universe_id, :user_id,
        :name, :type_of, :description,
        :map,
        :population, :currency, :motto,
        :capital, :largest_city, :notable_cities,
        :area, :crops, :located_at,
        :stablishment_year, :notable_wars,
        :notes, :private_notes)
    end
end
