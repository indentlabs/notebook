
class GovernmentsController < ContentController
  private

  def content_param_list
    [
      :name, :description, :type_of_government, :power_structure, :power_source,
      :checks_and_balances, :sociopolitical, :socioeconomical, :geocultural,
      :laws, :immigration, :privacy_ideologies, :electoral_process,
      :term_lengths, :criminal_system, :approval_ratings, :military, :navy,
      :airforce, :space_program, :international_relations, :civilian_life,
      :founding_story, :flag_design_story, :notable_wars, :notes,
      :private_notes, :privacy, :universe_id
    ] + [ #<relations>
      government_leaders_attributes: [:id, :leader_id, :_destroy],
      government_groups_attributes: [:id, :group_id, :_destroy],
      government_political_figures_attributes: [:id, :political_figure_id, :_destroy],
      government_items_attributes: [:id, :item_id, :_destroy],
      government_technologies_attributes: [:id, :technology_id, :_destroy],
      government_creatures_attributes: [:id, :creature_id, :_destroy]
    ]
  end
end
