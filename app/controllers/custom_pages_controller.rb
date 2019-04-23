class CustomPagesController < ContentController
  def create
    # todo inject page_type (or inject it into serializer at #new)
    super
  end

  private

  def content_param_list
    [
      :name, :universe_id, :privacy
    ] + [ #<relations>

    ]
  end
end
