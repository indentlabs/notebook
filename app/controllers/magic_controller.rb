# Controller for the Magic model
class MagicController < ContentController

  private

  def content_params
    params.require(:magic).permit(
      :universe_id, :user_id,
      :name, :type_of,
      :manifestation, :symptoms,
      :element, :diety,
      :harmfulness, :helpfulness, :neutralness,
      :resource, :skill_level, :limitations,
      :notes, :private_notes)
  end
end
