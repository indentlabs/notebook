class LocationLanguageship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :location
  belongs_to :language, optional: true
end
