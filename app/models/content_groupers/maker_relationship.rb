# Defines a relation from an Item to the Character that created it
# and an inverse relationship from a Character to all items it created
class MakerRelationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :item
  belongs_to :maker, class_name: 'Character'
end
