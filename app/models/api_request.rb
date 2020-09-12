class ApiRequest < ApplicationRecord
  belongs_to :application_integration,   optional: true
  belongs_to :integration_authorization, optional: true
end
