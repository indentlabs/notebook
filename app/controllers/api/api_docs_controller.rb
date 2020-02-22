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
    end

    def approvals
    end

    def references
    end
  end
end