class TechnologyMagic < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :technology
  belongs_to :magic, optional: true
end
