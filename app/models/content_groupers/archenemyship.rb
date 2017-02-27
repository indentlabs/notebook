class Archenemyship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :archenemy, class_name: 'Character'
end
