class Contributor < ActiveRecord
  belongs_to :universe
  belongs_to :user
end
