# Superclass for all model controllers
class ApplicationController < ActionController::Base
  protect_from_forgery

  def content_type_from_controller(content_controller_name)
    content_controller_name.to_s.chomp('Controller').singularize.constantize
  end
end
