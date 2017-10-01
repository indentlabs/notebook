class Contributor < ActiveRecord::Base
  belongs_to :universe
  belongs_to :user
end
