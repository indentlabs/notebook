class NavigatorController < ApplicationController
  layout 'app'

  def index
    @content_types = %w(Characters Locations Items Creatures Races Religions Groups Magics Languages Scenes)
  end
end
