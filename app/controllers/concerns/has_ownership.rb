# Module handles privacy and auth for controller content
module HasOwnership
  extend ActiveSupport::Concern

  included do
    before_action :require_ownership, only: [:edit, :update, :destroy]
  end

  module ClassMethods
    def owner
      user.id
    end
  end

  private

  def redirect_path
    model = content_type_from_controller(self.class)
    # TODO: proper pluralizing here
    "#{model.to_s.downcase}s_path"
  end

  def require_ownership
    model = content_type_from_controller(self.class)
    redirect_if_not_owned model.find(params[:id]), send(redirect_path)
  rescue
    redirect_to '/500'
  end

  def redirect_if_not_owned(object_to_check, redirect_path)
    return if owned_by_current_user? object_to_check
    redirect_to redirect_path, notice: t(:no_do_permission)
  end

  def owned_by_current_user?(object)
    current_user == object.user
  end
end
