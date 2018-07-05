class Deityship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :religion
  belongs_to :deity, class_name: 'Character'
end
