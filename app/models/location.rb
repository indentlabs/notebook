class Location < ActiveRecord::Base
  belongs_to :user
  belongs_to :universe
end
