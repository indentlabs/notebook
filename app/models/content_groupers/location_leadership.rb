class LocationLeadership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :location
  belongs_to :leader, class_name: 'Character'
end
