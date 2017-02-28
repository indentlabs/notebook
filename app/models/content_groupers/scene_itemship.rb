class SceneItemship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :scene
  belongs_to :scene_item, class_name: 'Item'
end