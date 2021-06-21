class Folder < ApplicationRecord
  belongs_to :parent_folder, optional: true, class_name: Folder.name
  belongs_to :user
end
