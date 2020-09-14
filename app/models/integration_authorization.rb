class IntegrationAuthorization < ApplicationRecord
  belongs_to :user
  belongs_to :application_integration

  has_many :api_requests
end
