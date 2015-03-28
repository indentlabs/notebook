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
    user = User.where(id: session[:user]).first

    @characters = user.characters
    @equipment = user.equipment
    @languages = user.languages
    @locations = user.locations
    @magics = user.magics
    @universes = user.universes

    @things = user.content_count
  end
end
