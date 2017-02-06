class Deityship < ActiveRecord::Base
  belongs_to :user

  belongs_to :religion
  belongs_to :deity, class_name: 'Character'
end
