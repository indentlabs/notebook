# Controller for the Universe model
class UniversesController < ContentController
  private

  def content_params
    params.require(:universe).permit(content_param_list)
  end

  def content_param_list
    [
      :user_id,
      :name, :description,
      :laws_of_physics, :magic_system, :technologies,
      :history,
      :privacy,
      :notes, :private_notes
    ]
  end
end
