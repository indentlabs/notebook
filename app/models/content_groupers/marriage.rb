class Marriage < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :spouse, class_name: 'Character'
end
