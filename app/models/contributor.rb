class Contributor < ApplicationRecord
  belongs_to :universe
  belongs_to :user
end
