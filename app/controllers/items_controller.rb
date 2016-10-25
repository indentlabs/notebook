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
      :notes, :private_notes, :privacy,

      # Relations
      custom_attribute_values:                  [:name, :value],
      original_ownerships_attributes:           [:id, :original_owner_id, :_destroy],
      current_ownerships_attributes:            [:id, :current_owner_id,  :_destroy],
      past_ownerships_attributes:               [:id, :past_owner_id,     :_destroy],
      maker_relationships_attributes:           [:id, :maker_id,          :_destroy],
    ]
  end
end
