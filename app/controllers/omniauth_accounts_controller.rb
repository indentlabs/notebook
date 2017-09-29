class OmniauthAccountsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    if current_user.omniauth_users.find(params[:id]).destroy
      flash[:notice] = 'The account was successfully disconnected.'
    else
      flash[:alert] = 'Something went wrong.'
    end
    redirect_to root_path
  end
end
