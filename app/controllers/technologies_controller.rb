
class TechnologiesController < ContentController
  private

  def content_param_list
    [
      :name, :description, :other_names, :materials, :manufacturing_process,
      :sales_process, :cost, :rarity, :purpose, :how_it_works, :resources_used,
      :physical_description, :size, :weight, :colors, :notes, :private_notes,
      :privacy, :universe_id
    ] + [ #<relations>
      technology_characters_attributes: [:id, :character_id, :_destroy],
      technology_towns_attributes: [:id, :town_id, :_destroy],
      technology_countries_attributes: [:id, :country_id, :_destroy],
      technology_groups_attributes: [:id, :group_id, :_destroy],
      technology_creatures_attributes: [:id, :creature_id, :_destroy],
      technology_planets_attributes: [:id, :planet_id, :_destroy],
      technology_magics_attributes: [:id, :magic_id, :_destroy],
      technology_parent_technologies_attributes: [:id, :parent_technology_id, :_destroy],
      technology_child_technologies_attributes: [:id, :child_technology_id, :_destroy],
      technology_related_technologies_attributes: [:id, :related_technology_id, :_destroy]
    ]
  end
end
