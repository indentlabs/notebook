class LocationLanguageship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :location
  belongs_to :language
end
