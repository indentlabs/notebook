class Folder < ApplicationRecord
  has_many :documents

  belongs_to :parent_folder, optional: true, class_name: Folder.name, foreign_key: :parent_folder_id
  belongs_to :user

  def child_folders
    Folder.where(user: self.user, context: self.context, parent_folder_id: self.id)
  end

  def self.color
    'bg-blue-600'
  end

  def self.hex_color
    '#0000ff'
  end

  def self.text_color
    'text-blue-600'
  end

  def self.icon
    'folder'
  end

  def to_param
    self.id.to_s + '-' + PageTagService.slug_for(self.title)
  end
end
