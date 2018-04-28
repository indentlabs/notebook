# Controller for the Location model
class LocationsController < ContentController
  autocomplete :location, :name
end
