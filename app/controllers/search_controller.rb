class SearchController < ApplicationController
  before_action :authenticate_user!

  layout 'tailwind'

  def results
    @query  = params[:q]
    @sort   = params[:sort] || 'relevance'
    @filter = params[:filter] || 'all'

    @matched_attributes = Attribute
      .where(user_id: current_user.id)
      .where('value ILIKE ?', "%#{@query}%")

    @result_types = @matched_attributes.pluck(:entity_type).uniq

    if @filter != 'all'
      @matched_attributes = @matched_attributes.where(entity_type: @filter)
    end

    case @sort
    when 'relevance'
      @matched_attributes = @matched_attributes.order(:entity_type, :entity_id)
    when 'recent'
      @matched_attributes = @matched_attributes.order(created_at: :desc)
    when 'oldest'
      @matched_attributes = @matched_attributes.order(created_at: :asc)
    end

    @seen_result_pages = {}
  end
end
