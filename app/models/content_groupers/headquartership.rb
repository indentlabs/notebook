class Headquartership < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :headquarter, class_name: 'Location'
end