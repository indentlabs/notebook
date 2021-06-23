class Folder < ApplicationRecord
  belongs_to :parent_folder, optional: true, class_name: Folder.name, foreign_key: :parent_folder_id
  belongs_to :user

  def child_folders
    Folder.where(user: self.user, context: self.context, parent_folder_id: self.id)
  end

  def self.color
    'teal lighten-1'
  end

  def self.icon
    'folder'
  end
end
