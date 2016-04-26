# Controller for the Equipment model
class ItemsController < ContentController
  private

  def content_params
    params.require(:item).permit(content_param_list)
  end

  def content_param_list
    [
      :universe_id, :user_id,
      :name, :item_type,
      :description, :weight,
      :original_owner, :current_owner, :made_by, :materials, :year_made,
      :magic,
      :notes, :private_notes
    ]
  end
end
