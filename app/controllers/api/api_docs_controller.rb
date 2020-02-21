module Api
  class ApiDocsController < ApplicationController
    layout 'developer'

    before_action :authenticate_user!, except: [:index]

    def index
    end

    def applications
    end
  end
end