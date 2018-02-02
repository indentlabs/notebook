class TechnologyGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :group
end
