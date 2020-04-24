# Defines a relation between a location and any notable cities within it,
# and a reverse relation for all locations in which a given location is notable within.
class NotableCitiesRelationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :location
  belongs_to :notable_city, class_name: 'Location', optional: true
end
