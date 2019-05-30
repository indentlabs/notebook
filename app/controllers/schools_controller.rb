
class SchoolsController < ContentController
  private

  def content_param_list
    [
      :name, :universe_id, :privacy, :page_type
    ] + [ #<relations>

    ]
  end
end
    