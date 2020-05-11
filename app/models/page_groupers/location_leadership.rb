class LocationLeadership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :location
  belongs_to :leader, class_name: 'Character', optional: true
end
