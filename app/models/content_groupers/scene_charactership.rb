class SceneCharactership < ActiveRecord::Base
  belongs_to :user

  belongs_to :scene
  belongs_to :scene_character, class_name: 'Character'
end