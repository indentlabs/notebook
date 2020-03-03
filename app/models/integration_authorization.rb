class IntegrationAuthorization < ApplicationRecord
  belongs_to :user
  belongs_to :application_integration
end
