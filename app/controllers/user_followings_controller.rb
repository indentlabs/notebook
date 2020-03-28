class UserFollowingsController < ApplicationController
  before_action :set_user_following, only: [:show, :edit, :update, :destroy]

  # GET /user_followings
  def index
    @user_followings = UserFollowing.all
  end

  # GET /user_followings/1
  def show
  end

  # GET /user_followings/new
  def new
    @user_following = UserFollowing.new
  end

  # GET /user_followings/1/edit
  def edit
  end

  # POST /user_followings
  def create
    @user_following = UserFollowing.new(user_following_params.merge({user_id: current_user.id}))

    if @user_following.save
      redirect_to @user_following.followed_user, notice: "You're now following #{@user_following.followed_user.name.presence || 'this user'}"
    else
      render :new
    end
  end

  # PATCH/PUT /user_followings/1
  def update
    if @user_following.update(user_following_params)
      redirect_to @user_following, notice: 'User following was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_followings/1
  def destroy
    user = @user_following.followed_user

    @user_following.destroy
    redirect_to user, notice: "You're no longer following this user."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_following
    @user_following = UserFollowing.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_following_params
    params.require(:user_following).permit(:followed_user_id)
  end
end
