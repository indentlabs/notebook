require 'active_support/concern'

module HasContentLinking
  extend ActiveSupport::Concern

  included do
    def after_add_handler x
    	raise x.inspect
    end

    def after_remove_handler x
    end
  end
end
