class GroupClientship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :group
  belongs_to :client, class_name: 'Group', optional: true
end
