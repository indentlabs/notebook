# Controller for the Location model
class LocationsController < ApplicationController
  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]

  before_action :require_ownership_of_location,
                only: [:update, :edit, :destroy]

  before_action :hide_private_location, only: [:show]

  def index
    @locations = Location.where(user_id: session[:user])
                 .order(:name).presence || []

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
    @location = create_location_from_params

    respond_to do |format|
      begin
        if @location.save
          notice = t(:create_success, Location.model_name.human) if notice.blank?
          format.html { redirect_to @location, notice: notice }
          format.json { render json: @location, status: :created, location: @location }
        else
          format.html { render action: 'new' }
          format.json { render json: @location.errors, status: :unprocessable_entity }
        end
      rescue Errno::ECONNRESET
        # Connection was reset, probably because of the file upload.
        # Try again without it.
        @location.map = nil
        notice = t :location_create_upload_map_error
        retry
      end
    end
  end

  def update
    @location = update_location_from_params

    respond_to do |format|
      begin
        if @location.update_attributes(location_params)
          notice = t :update_success, Location.model_name.human if notice.blank?
          format.html { redirect_to @location, notice: notice }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @location.errors, status: :unprocessable_entity }
        end
      rescue Errno::ECONNRESET
        # Connection was reset, probably because of the file upload.
        # Try again without it.
        @location.map = nil
        notice = t :location_update_upload_map_error
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
      :universe_id, :user_id, :name, :type_of, :description, :map,
      :population, :currency, :motto, :capital, :largest_city, :notable_cities,
      :area, :crops, :located_at, :stablishment_year, :notable_wars,
      :notes, :private_notes)
  end

  def create_location_from_params
    location = Location.new(location_params)
    location.user_id = session[:user]
    location.universe = universe_from_location_params
    location
  end

  def update_location_from_params
    params[:location][:universe] = universe_from_location_params
    Location.find(params[:id])
  end

  def universe_from_location_params
    Universe.where(user_id: session[:user],
                   name: params[:location][:universe].strip).first
  end
end
