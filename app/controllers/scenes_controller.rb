class ScenesController < ContentController
  private

  def content_params
    params.require(:scene).permit(content_param_list)
  end

  def content_param_list
    %i(
      name summary universe_id
      cause description results
      notes private_notes
    )
  end
end
