
class TechnologiesController < ContentController
  private

  def content_param_list
    [
      :name, :description, :other_names, :materials, :manufacturing_process, :sales_process, :cost, :rarity, :purpose, :how_it_works, :resources_used, :physical_description, :size, :weight, :colors, :notes, :private_notes, :privacy, :universe_id
    ] + [ #<relations>

    ]
  end
end
    