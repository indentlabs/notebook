class CustomizationController < ApplicationController
  def content_types
    #todo find where these were universally defined and use that instead :(
    @all_content_types = [
      Universe, Character, Location, Item, Creature, Race,
      Religion, Group, Magic, Language, Scene, Flora
    ]

    @premium_content_types = [
      Creature, Race, Religion, Group, Magic, Language, Scene, Flora
    ]

    @my_activators = current_user.user_content_type_activators.pluck(:content_type)
  end
end
