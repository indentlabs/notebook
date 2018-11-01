
class BuildingsController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :privacy, :page_type
    ] + [ #<relations>
      custom_attribute_values:     [:name, :value],
    ]
  end
end
