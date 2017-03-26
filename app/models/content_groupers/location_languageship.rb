class LocationLanguageship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :location
  belongs_to :language
end
