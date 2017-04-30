class NavigatorController < ApplicationController
  layout 'app'

  def index
    @universe = current_user.universes.first

    @content_types = %w(Characters Locations Items Creatures Races Religions Groups Magics Languages Scenes)
  end
end
