class Marriage < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :spouse, class_name: 'Character'
end
