class Document < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  include Authority::Abilities
  self.authorizer_name = 'DocumentAuthorizer'
end
