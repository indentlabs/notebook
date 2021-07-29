# lib/extensions/thredded/post.rb
# frozen_string_literal: true

module Extensions
  module Thredded
    module Post
      extend ActiveSupport::Concern
      
      included do
        acts_as_paranoid
      end
    end
  end
end