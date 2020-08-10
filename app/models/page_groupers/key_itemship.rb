class KeyItemship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :key_item, class_name: 'Item', optional: true
end
