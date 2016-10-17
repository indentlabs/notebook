class GroupsController < ContentController
  private

  def content_params
    params.require(:group).permit(content_param_list)
  end

  def content_param_list
    %i(
      name description other_names universe_id
      organization_structure
      motivation goal obstacles risks
      inventory
    )
  end
end
