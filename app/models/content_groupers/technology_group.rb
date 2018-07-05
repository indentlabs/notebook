class TechnologyGroup < ActiveRecord
  belongs_to :user
  belongs_to :technology
  belongs_to :group
end
