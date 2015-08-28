# Controller for the Universe model
class UniversesController < ApplicationController
  include HasOwnership

  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]

  before_action :hide_private_universe, only: [:show]

  def index
    @universes = Universe.where(user_id: session[:user]).order(:name).presence || []

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
    @universe = Universe.new(universe_params)
    @universe.user_id = session[:user]

    respond_to do |format|
      if @universe.save
        notice = t :create_success, model_name: Universe.model_name.human
        format.html { redirect_to @universe, notice: notice }
        format.json { render json: @universe, status: :created, location: @universe }
      else
        format.html { render action: 'new' }
        format.json { render json: @universe.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @universe = Universe.find(params[:id])

    respond_to do |format|
      if @universe.update_attributes(universe_params)
        notice = t :update_success, model_name: Universe.model_name.human
        format.html { redirect_to @universe, notice:  notice }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
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

  private

  def universe_params
    params.require(:universe).permit(
      :user_id,
      :name, :description,
      :history,
      :privacy,
      :notes, :private_notes)
  end
end
