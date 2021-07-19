class ApplicationIntegration < ApplicationRecord
  belongs_to :user

  has_many :integration_authorizations
  has_many :api_requests

  after_create :generate_new_access_token!

  def self.icon
    'extension'
  end

  def self.color
    'orange'
  end

  def self.text_color
    'orange-text'
  end

  def generate_new_access_token!
    self.update(application_token: SecureRandom.hex(24))
  end

  def request_error_rate
    @request_error_rate ||= begin
      errored_requests = api_requests.errored.count
      total_requests   = api_requests.count

      return 0 if total_requests.zero?
      (errored_requests.to_f / total_requests).round(3)
    end
  end

  def error_rate_color
    rate = request_error_rate

    case rate
    when 0.0..0.1
      'green'
    when 0.1..0.3
      'yellow'
    when 0.3..1
      'red'
    end
  end

  def current_quota_usage_percentage
    @current_quota_usage_percentage ||= ((api_requests.successful.count.to_f / 10_000) * 100).round(2)
  end
end
