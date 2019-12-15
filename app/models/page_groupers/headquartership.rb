class Headquartership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :headquarter, class_name: 'Location'
end
