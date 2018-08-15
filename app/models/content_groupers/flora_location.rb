class FloraLocation < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :flora
  belongs_to :location
end
