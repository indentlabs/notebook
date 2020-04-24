class SceneItemship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :scene
  belongs_to :scene_item, class_name: 'Item', optional: true
end
