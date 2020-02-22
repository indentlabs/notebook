module Api
  class ApiDocsController < ApplicationController
    layout 'developer', except: [:integrations]

    before_action :authenticate_user!, except: [:index]

    def index
    end

    def integrations
    end

    def applications
    end

    def approvals
    end

    def references
    end
  end
end