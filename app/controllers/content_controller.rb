class ContentController < ApplicationController
  include HasOwnership

  before_action :create_anonymous_account_if_not_logged_in, only: [:edit, :create, :update]
end
