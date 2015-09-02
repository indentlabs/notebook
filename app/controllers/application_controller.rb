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
end
