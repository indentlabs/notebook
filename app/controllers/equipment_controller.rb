# Controller for the Equipment model
class EquipmentController < ContentController
  private

  def content_params
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
    @equipment = @equipment.where(universe_id: @universe.id) if @equipment.blank?
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
