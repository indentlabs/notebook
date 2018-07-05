class SceneCharactership < ActiveRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :scene
  belongs_to :scene_character, class_name: 'Character'
end
