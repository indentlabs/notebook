class MagicDeityship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :magic
  belongs_to :deity, class_name: 'Character', optional: true
end
