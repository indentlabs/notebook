class Officeship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :office, class_name: 'Location'
end
