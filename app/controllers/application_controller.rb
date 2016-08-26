# Superclass for all model controllers
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action do
    if params[:universe].present?
      if params[:universe] == 'all'
        session.delete(:universe_id)
      elsif params[:universe].is_a?(String) && params[:universe].to_i.to_s == params[:universe]
        found_universe = Universe.find_by(user: current_user, id: params[:universe])
        session[:universe_id] = found_universe.id if found_universe
      end
    end
  end

  before_action do
    if current_user && session[:universe_id]
      @universe_scope = Universe.find_by(user: current_user, id: session[:universe_id])
    end
  end

  def content_type_from_controller(content_controller_name)
    content_controller_name.to_s.chomp('Controller').singularize.constantize
  end
end
