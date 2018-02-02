class TechnologyMagic < ActiveRecord::Base
  belongs_to :user
  belongs_to :technology
  belongs_to :magic
end
