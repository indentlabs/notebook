class CustomizationController < ApplicationController
  before_action :verify_content_type_can_be_toggled, only: [:toggle_content_type]

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

  def toggle_content_type
    current_activator = current_user
      .user_content_type_activators
      .where(content_type: toggle_content_type_params[:content_type])

    if current_activator.any?
      current_activator.destroy_all
    else
      current_user
        .user_content_type_activators
        .create(content_type: toggle_content_type_params[:content_type])
    end
  end

  def verify_content_type_can_be_toggled
    return false unless toggle_content_type_value_whitelist.include?(toggle_content_type_params[:content_type])
  end

  private

  def toggle_content_type_params
    params.permit(:content_type, :active)
  end

  def toggle_content_type_value_whitelist
    [
      Character, Location, Item, Creature, Race, Religion,
      Group, Magic, Language, Scene, Flora
    ].map(&:to_s)
  end
end
