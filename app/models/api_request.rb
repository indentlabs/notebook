class ApiRequest < ApplicationRecord
  belongs_to :application_integration
  belongs_to :integration_authorization
end
