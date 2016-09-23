# Module handles privacy and auth for controller content
module HasOwnership
  extend ActiveSupport::Concern

  included do
    before_action :require_ownership_or_sharing, only: [:show]
    before_action :require_ownership, only: [:edit, :update, :destroy]
  end

  module ClassMethods
    def owner # TODO: is this even used?
      user.id
    end
  end

  private

  # Ensures that only the owner can do this action
  def require_ownership
    model = content_type_from_controller(self.class)
    redirect_if_not_owned model.find(params[:id]), send(redirect_path)
  rescue
    redirect_to '/500'
  end

  # Unless this content is shared, ensure only the owner can do this action
  def require_ownership_or_sharing
    model = content_type_from_controller(self.class).find(params[:id])
    unless model.user == current_user || publicly_shared?(model)
      if current_user
        redirect_to send(redirect_path), notice: t(:no_do_permission)
      else
        redirect_to new_user_session_path, notice: t(:no_do_permission)
      end
    end
  end

  # Redirect the user to redirect_path unless they own this content
  def redirect_if_not_owned(object_to_check, redirect_path)
    if current_user.nil?
      redirect_to new_user_session_path, notice: t(:no_do_permission)
    elsif current_user != object_to_check.user
      redirect_to send(redirect_path), notice: t(:no_do_permission)
    end
  end

  def redirect_path
    model = content_type_from_controller(self.class)
    # TODO: proper pluralizing here
    "#{model.to_s.downcase}s_path"
  end

  def owned_by_current_user?(object)
    current_user == object.user
  end

  def publicly_shared?(object)
    object_is_public = object.respond_to?(:privacy) && object.privacy.present? && object.privacy.casecmp('public').zero?
    object_universe_is_public = object.respond_to?(:universe) && object.universe.present? && object.universe.privacy.casecmp('public').zero?

    # If either the content or the universe it's in are public, we treat the object as public
    object_is_public || object_universe_is_public
  end
end
