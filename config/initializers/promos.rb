Rails.application.config.promos = {}

Rails.application.config.promos[:promo_bogo] = {}
Rails.application.config.promos[:promo_bogo][:start_date] = 'March 20, 2020'.to_date
Rails.application.config.promos[:promo_bogo][:end_date] = Rails.application.config.promos[:promo_bogo][:start_date] + 2.weeks
