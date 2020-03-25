Rails.application.config.promos = {}

# BOGO on Premium Codes
Rails.application.config.promos[:promo_bogo] = {}
Rails.application.config.promos[:promo_bogo][:start_date] = 'March 21, 2020'.to_date
Rails.application.config.promos[:promo_bogo][:end_date] = Rails.application.config.promos[:promo_bogo][:start_date] + 2.weeks

# Lore free during the month of April
if Date.current >= 'March 1, 2020'.to_date
  if Date.current < 'May 1, 2020'.to_date
    Rails.application.config.content_types[:free] << Lore
  end
end
