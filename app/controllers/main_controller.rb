# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  before_action :redirect_if_not_logged_in, only: [:dashboard]

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def comingsoon
  end

  def anoninfo
  end

  def attribution
  end

  def dashboard
    #todo just use @user in the view
    user = User.where(id: current_user.id).first

    @characters = user.characters
    @equipment = user.equipment
    @languages = user.languages
    @locations = user.locations
    @magics = user.magics
    @universes = user.universes

    @things = user.content_count
  end
end
