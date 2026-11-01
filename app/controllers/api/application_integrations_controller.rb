module Api
  class ApplicationIntegrationsController < ApplicationController
    layout 'developer'

    before_action :authenticate_user!
    before_action :set_integration, only: [:show, :authorize, :edit, :update, :destroy]

    # GET /application_integrations
    def index
      @applications = current_user.application_integrations
    end

    # GET /application_integrations/1
    def show
    end

    def authorize
    end

    # GET /application_integrations/new
    def new
      @application_integration = ApplicationIntegration.new
    end

    # GET /application_integrations/1/edit
    def edit
    end

    # POST /application_integrations
    def create
      @application_integration = ApplicationIntegration.new(application_integration_params.merge({user: current_user}))

      if @application_integration.save
        redirect_to api_application_path(@application_integration), notice: 'Application integration was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /application_integrations/1
    def update
      if @application_integration.update(application_integration_params)
        redirect_to api_application_path(@application_integration), notice: 'Application integration was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /application_integrations/1
    def destroy
      @application_integration.destroy
      redirect_to api_applications_path, notice: 'Application integration was successfully destroyed.'
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_integration
      # Raises RecordNotFound (a 404) for someone else's application.
      @application_integration = current_user.application_integrations.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def application_integration_params
      params.require(:application_integration).permit(
        :name, :description, :organization_name, :organization_url, :website_url, :privacy_policy_url, :authorization_callback_url
      )
    end
  end
end