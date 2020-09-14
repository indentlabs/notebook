class ApiRequest < ApplicationRecord
  belongs_to :application_integration,   optional: true
  belongs_to :integration_authorization, optional: true

  scope :successful, -> { where(result: 'success') }
  scope :errored,    -> { where(result: 'error')   }
end
