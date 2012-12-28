class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def is_logged_in?
    session[:user]
  end
  
  def redirect_if_not_logged_in
    unless is_logged_in?
      redirect_to login_path, :notice => "You must be logged in to do that!"
    end
  end
  
  def require_ownership_of_character
  	character = Character.find(params[:id])
  	unless session[:user] and session[:user] == character.user.id
  	  redirect_to character_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_equipment
  	equipment = Equipment.find(params[:id])
  	unless session[:user] and session[:user] == equipment.user.id
  	  redirect_to equipment_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_language
  	language = Language.find(params[:id])
  	unless session[:user] and session[:user] == language.user.id
  	  redirect_to language_list_path, :notice => "You don't have permission to do that!"
  	end
  end
  
  def require_ownership_of_location
  	location = Location.find(params[:id])
  	unless session[:user] and session[:user] == location.user.id
  	  redirect_to location_list_path, :notice => "You don't have permission to do that!"
  	end
  end
end
