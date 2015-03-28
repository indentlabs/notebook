# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  before_action :redirect_if_not_logged_in, only: [:dashboard]

  def index
    redirect_to :dashboard if session && session[:user]
  end

  def comingsoon
  end

  def anoninfo
  end

  def attribution
  end

  def dashboard
    fetch_all_models

    @things = content_count
  end

  def fetch_all_models
    userid = session[:user]

    @characters = Character.where(user_id: userid)
    @equipment = Equipment.where(user_id: userid)
    @languages = Language.where(user_id: userid)
    @locations = Location.where(user_id: userid)
    @magics = Magic.where(user_id: userid)
    @universes = Universe.where(user_id: userid)
  end

  def content_count
    [
      @characters.length,
      @equipment.length,
      @languages.length,
      @locations.length,
      @magics.length,
      @universes.length
    ].sum
  end
end
