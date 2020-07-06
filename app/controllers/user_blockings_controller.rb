class UserBlockingsController < ApplicationController
  before_action :set_user_blocking, only: [:show, :edit, :update, :destroy]

  # GET /user_blockings
  def index
    @user_blockings = UserBlocking.all
  end

  # GET /user_blockings/1
  def show
  end

  # GET /user_blockings/new
  def new
    @user_blocking = UserBlocking.new
  end

  # GET /user_blockings/1/edit
  def edit
  end

  # POST /user_blockings
  def create
    @user_blocking = UserBlocking.new(user_blocking_params.merge({user_id: current_user.id}))

    if @user_blocking.save
      redirect_to @user_blocking.blocked_user, notice: 'This user has been blocked.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_blockings/1
  def update
    if @user_blocking.update(user_blocking_params)
      redirect_to @user_blocking, notice: 'User blocking was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_blockings/1
  def destroy
    user = @user_blocking.blocked_user

    @user_blocking.destroy
    redirect_to user, notice: 'You are no longer blocking this user.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_blocking
    @user_blocking = UserBlocking.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_blocking_params
    params.require(:user_blocking).permit(:blocked_user_id)
  end
end
