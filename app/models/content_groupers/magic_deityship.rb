class MagicDeityship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :magic
  belongs_to :deity, class_name: 'Character'
end
