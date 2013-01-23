class UsersController < ApplicationController
  before_filter :redirect_if_not_logged_in, :only => [:edit, :update]
  
  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(session[:user])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
		    session[:user] = @user.id
        format.html { redirect_to homepage_path, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

	def anonymous_login
		id = rand(10000000).to_s + rand(10000000).to_s
    @user = User.new(:name => 'Anonymous-' + id.to_s, :email => id.to_s + '@localhost', :password => id.to_s)

    respond_to do |format|
      if @user.save
		    session[:user] = @user.id
        format.html { redirect_to homepage_path, notice: 'You have been logged in to a temporary account that will delete itself (and everything you create with it!) as soon as you log out.' }
        format.json { render json: @user, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
	end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(session[:user])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to homepage_path, notice: 'Successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def anonymous
  end
end
