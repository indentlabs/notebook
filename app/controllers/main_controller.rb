class MainController < ApplicationController
  before_filter :redirect_if_not_logged_in, :only => [:dashboard]
  
  def index
  end
  
  def comingsoon
  end
  
  def dashboard
    @characters = Character.where(user_id: session[:user])
    @equipment = Equipment.where(user_id: session[:user])
    @languages = Language.where(user_id: session[:user])
    @locations = Location.where(user_id: session[:user])
    @magics = Magic.where(user_id: session[:user])
    @universes = Universe.where(user_id: session[:user])
    
    @things = [ @characters.length, @equipment.length, @languages.length, 
                @locations.length, @magics.length, @universes.length ].sum
  end
end
