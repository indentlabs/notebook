# Defines a relation between a location and any capital cities within it,
# and a reverse relation for all locations in which they are the capital of.
class CapitalCitiesRelationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :location
  belongs_to :capital_city, class_name: 'Location', optional: true
end
