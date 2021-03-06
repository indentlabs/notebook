# Defines a relation from an Item to the Character that first owned it
# and an inverse relationship from a Character to all items it first owned
class OriginalOwnership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :item
  belongs_to :original_owner, class_name: 'Character', optional: true
end
