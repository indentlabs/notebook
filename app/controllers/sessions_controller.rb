# Controller for user Sessions
class SessionsController < ApplicationController
  # GET /sessions/new
  # GET /sessions/new.json
  def new
    @session = Session.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @session }
    end
  end

  # POST /sessions
  # POST /sessions.json
  def create
    user = user_from_params

    if user.nil?
      redirect_to login_path, notice: t(:username_password_incorrect)
      return
    end

    build_session_for user

    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: t(:login_successful) }
      format.json { render json: true, status: :created }
    end
  end

  # GET /logout
  def destroy
    session.delete(:user)
    session.delete(:anon_user)

    respond_to do |format|
      format.html { redirect_to homepage_path, notice: t(:logged_out) }
      format.json { head :no_content }
    end
  end

  def self.create_password_digest(username, password)
    require 'digest'
    Digest::MD5.hexdigest(
      username + "'s password IS... " + password + ' (lol!)')
  end

  private

  def user_from_params
    login = Session.new(session_params)
    user = User.find_by(name: login.username)
    migrate_to_bcrypt(user, login.password) if user.old_password.present?
    user.try(:authenticate, login.password)
  end

  def migrate_to_bcrypt(user, password)
    hash = SessionsController.create_password_digest user.name, password

    return unless user.old_password == hash

    user.old_password = nil
    user.password = password
    user.save
  end

  def build_session_for(user)
    session[:user] = user.id
    session.delete(:anon_user)
  end

  def session_params
    params.require(:session).permit(:username, :password)
  end
end
