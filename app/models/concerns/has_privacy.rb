require 'active_support/concern'

module HasPrivacy
  extend ActiveSupport::Concern

  included do
    def private_content?
      !public_content?
    end

    def public_content?
      in_private_universe = respond_to?(:universe) && universe.present? && universe.private_content?
      privacy == 'public' && !in_private_universe
    end
  end
end
