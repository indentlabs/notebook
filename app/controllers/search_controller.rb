class SearchController < ApplicationController
  before_action :authenticate_user!

  layout 'tailwind'

  def results
    @query = params[:q]

    @matched_attributes = Attribute
      .where(user_id: current_user.id)
      .where('value ILIKE ?', "%#{@query}%")
      .order(:entity_type, :entity_id)

    @seen_result_pages = {}
  end
end
