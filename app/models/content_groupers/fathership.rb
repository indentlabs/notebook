class Fathership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :character
  belongs_to :father, class_name: 'Character'

  def self.after_add
  	puts "OK"
  end
end
