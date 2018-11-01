
class VehiclesController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :privacy
    ] + [ #<relations>

    ]
  end
end
    