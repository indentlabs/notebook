class Location < ActiveRecord::Base
  def create
    Location.create(params.permit!)
  end
end
