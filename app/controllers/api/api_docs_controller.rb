module Api
  class ApiDocsController < ApplicationController
    layout 'developer', except: [:integrations]

    before_action :authenticate_user!, except: [:index, :references]

    def index
    end

    def integrations
    end

    def pricing
    end

    def applications
      @applications = current_user.application_integrations
    end

    def approvals
    end

    def references
    end
  end
end