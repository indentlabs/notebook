class SceneItemship < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :scene
  belongs_to :scene_item, class_name: 'Item'
end
