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
end
