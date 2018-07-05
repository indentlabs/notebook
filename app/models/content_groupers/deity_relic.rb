class DeityRelic < ActiveRecord
  belongs_to :user
  belongs_to :deity
  belongs_to :relic, class_name: Item.name
end
