class Siblingship < ActiveRecord::Base
  belongs_to :user

  belongs_to :character
  belongs_to :sibling, class_name: 'Character'
end
