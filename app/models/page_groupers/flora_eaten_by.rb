class FloraEatenBy < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :flora
  belongs_to :creature, optional: true
end
