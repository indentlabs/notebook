# Controller for the User model
class UsersController < ApplicationController
  before_action :redirect_if_not_logged_in, only: [:edit, :update]

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
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        log_in @user
        notice = t(:create_success, model_name: User.model_name.human)
        format.html { redirect_to homepage_path, notice: notice }
        format.json { render json: @user, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def anonymous_login
    @user = create_anonymous_user

    respond_to do |format|
      if @user.save
        session[:user] = @user.id
        session[:anon_user] = true
        format.html { redirect_to dashboard_path }
        format.json { render json: @user, status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(session[:user])

    respond_to do |format|
      if @user.update_attributes(user_params)
        session[:anon_user] = false
        format.html { redirect_to homepage_path, notice: 'Successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def anonymous
  end

  private

  def user_params
    params.require(:user).permit(:name, :password, :email)
  end
end
