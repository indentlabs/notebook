class GroupLocationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :group
  belongs_to :location
end
