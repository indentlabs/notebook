class Officeship < ActiveRecord::Base
  belongs_to :user

  belongs_to :group
  belongs_to :office, class_name: 'Location'
end