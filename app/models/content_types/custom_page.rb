class CustomPage < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'CoreContentAuthorizer' # CustomContentAuthorizer
end
