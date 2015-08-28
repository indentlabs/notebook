# Controller for the Equipment model
class EquipmentController < ApplicationController
  include HasOwnership

  before_action :create_anonymous_account_if_not_logged_in,
                only: [:edit, :create, :update]

  before_action :hide_private_equipment, only: [:show]

  def index
    @equipment = Equipment
                 .where(user_id: session[:user])
                 .order(:name).presence || []

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @equipment }
    end
  end

  def show
    @equipment = Equipment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @equipment }
    end
  end

  def new
    @equipment = Equipment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @equipment }
    end
  end

  def edit
    @equipment = Equipment.find(params[:id])
  end

  def create
    @equipment = create_equipment_from_params

    # rubocop:disable LineLength
    respond_to do |format|
      if @equipment.save
        format.html { redirect_to @equipment, notice: t(:create_success, model_name: Equipment.model_name.human) }
        format.json { render json: @equipment, status: :created, location: @equipment }
      else
        format.html { render action: 'new' }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
    end
    # rubocop:enable LineLength
  end

  def update
    @equipment = update_equipment_from_params

    # rubocop:disable LineLength
    respond_to do |format|
      if @equipment.update_attributes(equipment_params)
        format.html { redirect_to @equipment, notice: t(:update_success, model_name: Equipment.model_name.human) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @equipment.errors, status: :unprocessable_entity }
      end
    end
    # rubocop:enable LineLength
  end

  def destroy
    @equipment = Equipment.find(params[:id])
    @equipment.destroy

    respond_to do |format|
      format.html { redirect_to equipment_list_url }
      format.json { head :no_content }
    end
  end

  private

  def equipment_params
    params.require(:equipment).permit(
      :universe_id, :user_id,
      :name, :equip_type,
      :description, :weight,
      :original_owner, :current_owner, :made_by, :materials, :year_made,
      :magic,
      :notes, :private_notes)
  end

  def populate_universe_fields
    @universe = Universe.where(user_id: session[:user],
                               name: params[:universe].strip).first
    @equipment =
      @equipment.where(universe_id: @universe.id) if @equipment.blank?
  end

  def universe_from_equipment_params
    Equipment.where(user_id: session[:user],
                    name: params[:equipment][:universe].strip).first.presence
  end

  def create_equipment_from_params
    equipment = Equipment.create(equipment_params)
    equipment.user_id = session[:user]
    equipment.universe = universe_from_equipment_params
    equipment
  end

  def update_equipment_from_params
    params[:equipment][:universe] = universe_from_equipment_params
    Equipment.find(params[:id])
  end

  def render_json_error_unprocessable
    render json: @equipment.errors, status: :unprocessable_entity
  end

  def render_html_success(notice)
    redirect_to @equipment, notice: notice
  end
end
