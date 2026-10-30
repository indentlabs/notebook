class UserBlockingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_blocking, only: [:destroy]

  # POST /user_blockings
  def create
    @user_blocking = UserBlocking.new(user_blocking_params.merge({user_id: current_user.id}))

    if @user_blocking.save
      redirect_to @user_blocking.blocked_user, notice: 'This user has been blocked.'
    else
      redirect_back fallback_location: root_path, alert: 'There was a problem blocking this user. Please try again.'
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
    @user_blocking = current_user.user_blockings.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_blocking_params
    params.require(:user_blocking).permit(:blocked_user_id)
  end
end
