require 'active_support/concern'

module HasPrivacy
  extend ActiveSupport::Concern

  included do
    def private_content?
      !public_content?
    end

    def public_content?
      universe_is_public = respond_to?(:universe) && universe.present? && universe.public_content?
      privacy == 'public' || universe_is_public
    end
  end
end
