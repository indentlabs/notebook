# Module handles privacy and auth for controller content
module HasOwnership
  extend ActiveSupport::Concern

  included do
    before_action :require_ownership, only: [:edit, :update, :destroy]
    before_action :hide_if_private, only: [:show]
  end

  private

  def redirect_path
    model = content_type_from_controller(self.class)
    "#{model.to_s.downcase}_list_path"
  end

  def require_ownership
    model = content_type_from_controller(self.class)
    redirect_if_not_owned model.find(params[:id]), send(redirect_path)
  rescue
    redirect_to '/'
  end

  def hide_if_private
    return # todo this
    return if try(:privacy).try(:downcase) == 'public'

    model = content_type_from_controller(self.class)
    redirect_if_private model.find(params[:id]), redirect_path
  rescue
    redirect_to '/'
  end

  def redirect_if_not_owned(object_to_check, redirect_path)
    return if owned_by_current_user? object_to_check
    redirect_to redirect_path, notice: t(:no_do_permission)
  end

  def redirect_if_private(object_to_check, redirect_path)
    return if visble? object_to_check
    redirect_to redirect_path, notice: t(:no_view_permission)
  end

  def owned_by_current_user?(object)
    current_user == object.user
  end

  def visible?(object)
    [
      owned_by_current_user?(object),
      object.universe.try(:privacy).try(:downcase) == 'public'
    ].any?
  end

  module ClassMethods
    def owner
      user.id
    end
  end
end
