class Archenemyship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :character
  belongs_to :archenemy, class_name: 'Character', optional: true
end
