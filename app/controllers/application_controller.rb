class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action do
    if params[:universe].present? && user_signed_in?
      if params[:universe] == 'all'
        session.delete(:universe_id)
      elsif params[:universe].is_a?(String) && params[:universe].to_i.to_s == params[:universe]
        found_universe = Universe.find_by(id: params[:universe])
        found_universe = nil unless current_user.universes.include?(found_universe) || current_user.contributable_universes.include?(found_universe)
        session[:universe_id] = found_universe.id if found_universe
      end
    end
  end

  before_action do
    if current_user && session[:universe_id]
      @universe_scope = Universe.find_by(id: session[:universe_id])
      @universe_scope = nil unless current_user.universes.include?(@universe_scope) || current_user.contributable_universes.include?(@universe_scope)
    else
      @universe_scope = nil
    end
  end

  before_action do
    @page_title ||= ''
    @page_keywords ||= %w[writing author nanowrimo novel character fiction fantasy universe creative dnd roleplay larp game design]
    @page_description ||= 'Notebook is a set of tools for writers, game designers, and roleplayers to create magnificent universes — and everything within them.'
  end

  before_action do
    @question ||= ''
  end

  def content_type_from_controller(content_controller_name)
    content_controller_name.to_s.chomp('Controller').singularize.constantize
  end
end
