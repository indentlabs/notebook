class WriteController < ApplicationController
  layout 'editor'

  def editor
    # TODO: Allow writers to specify a universe to scope content to, instead of all content
    @characters = current_user.characters
    @locations  = current_user.locations
    @items      = current_user.items
  end
end
