class UserBlocking < ApplicationRecord
  belongs_to :user
  belongs_to :blocked_user, class_name: User.name
end
