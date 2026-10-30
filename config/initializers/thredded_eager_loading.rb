# frozen_string_literal: true

# Extend Thredded's PrivateTopicsPageView to include :last_post in eager loading
# This prevents N+1 queries when displaying the last post preview on the private topics index
Rails.application.config.to_prepare do
  Thredded::PrivateTopicsPageView.class_eval do
    def refine_scope(topics_page_scope)
      topics_page_scope.includes(:user, :last_user, :users, :last_post)
    end
  end
end
