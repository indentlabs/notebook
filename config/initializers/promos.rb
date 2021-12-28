Rails.application.config.promos = {}

# BOGO on Premium Codes
# March 21, 2020 -- April 4, 2020
Rails.application.config.promos[:promo_bogo] = {}
Rails.application.config.promos[:promo_bogo][:start_date] = 'March 21, 2020'.to_date
Rails.application.config.promos[:promo_bogo][:end_date] = Rails.application.config.promos[:promo_bogo][:start_date] + 2.weeks

# Lore free during the month of April, 2020
# Need to change Lore.rb authorizer at the end lol
if Date.current >= 'March 1, 2020'.to_date
  if Date.current < 'April 1, 2020'.to_date
    Rails.application.config.content_types[:free] << Lore
    Rails.application.config.content_types[:premium] -= [Lore]
  end
end

# Lore free during the month of October
# Need to change Creature.rb authorizer at the end
if Date.current >= 'October 1, 2021'.to_date
  if Date.current < 'November 1, 2021'.to_date
    Rails.application.config.content_types[:free] << Creature
    Rails.application.config.content_types[:premium] -= [Creature]
  end
end
