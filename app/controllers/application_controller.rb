# Superclass for all model controllers
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper :html
  helper :my_content

  helper_method :nl2br
  helper_method :universe_filter

  # Rails changed cookie format in rails 4, so log out all old users so that
  # they get the new version
  rescue_from JSON::ParserError, with: :force_user_logout
  def force_user_logout
    reset_session
    redirect_to login_path
  end

  # View Helpers
  def nl2br(string)
    # simple_format string
    string.gsub("\n\r", '<br>').gsub("\r", '').gsub("\n", '<br />').html_safe
  end

  def universe_filter
    return if User.find_by(id: session[:user]).universes.empty?
    @selected_universe_filter ||= t(:all_universes)
  end

  # Authentication
  # replace with devise
  def log_in(user)
    session[:user] = user.id
  end

  def logged_in?
    session && session[:user]
  end

  def redirect_if_not_logged_in
    return if logged_in?
    redirect_to signup_path, notice: t(:must_be_logged_in)
  end

  def create_anonymous_account_if_not_logged_in
    return if logged_in?

    # layman's collision detection
    10.times do
      @user = create_anonymous_user
      break if @user.save
    end

    return if @user.nil?

    session[:user] = @user.id
    session[:anon_user] = true
  end

  def create_anonymous_user
    # TODO: guarantee anonymous id is random (or just let db assign it?)
    id = rand(10_000_000).to_s + rand(10_000_000).to_s # lol

    User.new(
      name: 'Anonymous-' + id.to_s,
      email: id.to_s + '@localhost',
      password: id.to_s)
  end

  def require_ownership
    model = self.class.to_s.chomp("Controller").singularize.constantize
    redirect_if_not_owned model.find(params[:id]), send("#{model.to_s.downcase}_list_path")
  rescue
    redirect_to '/'
  end

  def hide_private_universe
    return if Universe.find(params[:id]).privacy.downcase == 'public'
    redirect_to universe_list_path, notice: t(:no_view_permission)
  end

  def hide_private_character
    redirect_if_private Character.find(params[:id]), character_list_path
  end

  def hide_private_equipment
    redirect_if_private Equipment.find(params[:id]), equipment_list_path
  end

  def hide_private_language
    redirect_if_private Language.find(params[:id]), language_list_path
  end

  def hide_private_location
    redirect_if_private Location.find(params[:id]), location_list_path
  end

  def hide_private_magic
    redirect_if_private Magic.find(params[:id]), magic_list_path
  end

  private

  def redirect_if_not_owned(object_to_check, redirect_path)
    return if owned_by_current_user? object_to_check
    redirect_to redirect_path, notice: t(:no_do_permission)
  end

  def redirect_if_private(object_to_check, redirect_path)
    return if public? object_to_check
    redirect_to redirect_path, notice: t(:no_view_permission)
  end

  def owned_by_current_user?(object)
    session[:user] && session[:user] == object.user.id
  end

  def public?(object)
    (owned_by_current_user? object) || \
      (object.universe && object.universe.privacy.downcase == 'public')
  end
end
