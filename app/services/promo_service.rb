class PromoService < Service
  def self.active?(promo_key)
    [
      Date.current >= Rails.application.config.promos.fetch(promo_key, {}).fetch(:start_date),
      Date.current <= Rails.application.config.promos.fetch(promo_key, {}).fetch(:end_date)
    ].all?
  rescue false
  end

  def self.end_date(promo_key)
    Rails.application.config.promos.fetch(promo_key, {}).fetch(:end_date)
  end
end