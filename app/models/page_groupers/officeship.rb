class Officeship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :office, class_name: 'Location'
end
