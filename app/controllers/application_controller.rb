# Superclass for all model controllers
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :html
  helper :my_content

  helper_method :nl2br
  helper_method :universe_filter

  # View Helpers
  def nl2br(string)
    # simple_format string
    string.gsub("\n\r", '<br>').gsub("\r", '').gsub("\n", '<br />').html_safe
  end

  def universe_filter
    return if User.find_by(id: current_user.id).universes.empty?
    @selected_universe_filter ||= t(:all_universes)
  end

  def content_type_from_controller(content_controller_name)
    content_controller_name.to_s.chomp('Controller').singularize.constantize
  end
end
