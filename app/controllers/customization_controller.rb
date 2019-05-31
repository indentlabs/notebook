class CustomizationController < ApplicationController
  before_action :verify_content_type_can_be_toggled, only: [:toggle_content_type]

  def content_types
    return redirect_to(root_path) unless user_signed_in?

    @all_content_types = Rails.application.config.content_types[:all]
    @premium_content_types = Rails.application.config.content_types[:premium]
    @my_activators = current_user.user_content_type_activators.pluck(:content_type)
    @sidenav_expansion = 'worldbuilding'
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

    redirect_to customization_content_types_path
  end

  def verify_content_type_can_be_toggled
    return false unless toggle_content_type_value_whitelist.include?(toggle_content_type_params[:content_type])
  end

  private

  def toggle_content_type_params
    params.permit(:content_type, :active)
  end

  def toggle_content_type_value_whitelist
    (
      Rails.application.config.content_types[:all] - Rails.application.config.content_types[:always_on]
    ).map(&:name)
  end
end
