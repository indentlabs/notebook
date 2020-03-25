
class LoresController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :archived_at, :privacy, :favorite, :page_type
    ] + [ #<relations>

    ]
  end
end
    