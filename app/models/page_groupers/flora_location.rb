class FloraLocation < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :flora
  belongs_to :location
end
