class Headquartership < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :headquarter, class_name: 'Location'
end