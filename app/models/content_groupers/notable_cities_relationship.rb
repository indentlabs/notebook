# Defines a relation between a location and any notable cities within it,
# and a reverse relation for all locations in which a given location is notable within.
class NotableCitiesRelationship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :location
  belongs_to :notable_city, class_name: 'Location'
end
