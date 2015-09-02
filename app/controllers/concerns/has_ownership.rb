# Module handles privacy and auth for controller content
module HasOwnership
  extend ActiveSupport::Concern

  included do
    before_action :require_ownership, only: [:edit, :update, :destroy]
    before_action :hide_if_private, only: [:show]
  end

  private

  def redirect_path
    model = self.class.to_s.chomp('Controller').singularize.constantize
    "#{model.to_s.downcase}_list_path"
  end

  def require_ownership
    model = self.class.to_s.chomp('Controller').singularize.constantize
    redirect_if_not_owned model.find(params[:id]), send(redirect_path)
  rescue
    redirect_to '/'
  end

  def hide_if_private
    return if try(:privacy).try(:downcase) == 'public'

    model = self.class.to_s.chomp('Controller').singularize.constantize
    redirect_if_private model.find(params[:id]), redirect_path
  rescue
    redirect_to '/'
  end

  def redirect_if_not_owned(object_to_check, redirect_path)
    return if owned_by_current_user? object_to_check
    redirect_to redirect_path, notice: t(:no_do_permission)
  end

  def redirect_if_private(object_to_check, redirect_path)
    return if public? object_to_check
    redirect_to redirect_path, notice: t(:no_view_permission)
  end

  def owned_by_current_user?(object)
    session[:user] && session[:user] == object.user.id
  end

  def public?(object)
    (owned_by_current_user? object) || \
      (object.universe && object.universe.privacy.downcase == 'public')
  end

  module ClassMethods
    def owner
      user.id
    end
  end
end
