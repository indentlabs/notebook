module SearchHelper
  def search_params
    params.permit(:q, :sort, :filter)
  end
end