class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def is_logged_in?
    session[:user]
  end
end
