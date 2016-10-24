class MagicDeityship < ActiveRecord::Base
  belongs_to :user

  belongs_to :magic
  belongs_to :deity, class_name: 'Character'
end