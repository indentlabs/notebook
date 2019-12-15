# Defines a relation from an Item to a Character that previously owned it
# and an inverse relationship from an Item to all Characters it has been owned by
class PastOwnership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :item
  belongs_to :past_owner, class_name: 'Character'
end
