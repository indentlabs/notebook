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
    require 'digest'
    login = Session.new(params[:session])
    
    hash = Digest::MD5.hexdigest(login.username + "'s password IS... " + login.password + " (lol!)")
    user = User.where(name: login.username, password: hash)
    if user.length < 1
      redirect_to login_path, notice: 'Username or password incorrect'
      return
    end
    
    session[:user] = user[0].id
      
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: 'Login successful.' }
      format.json { render json: true, status: :created }
	  end

  end

  # GET /logout
  def destroy
    session.delete(:user)

    respond_to do |format|
      format.html { redirect_to homepage_path, notice: 'Logged out!' }
      format.json { head :no_content }
    end
  end
end
