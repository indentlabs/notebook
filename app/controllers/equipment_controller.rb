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
end
