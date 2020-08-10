class TechnologyGroup < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :group, optional: true
end
