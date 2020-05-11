class SceneCharactership < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :scene
  belongs_to :scene_character, class_name: 'Character', optional: true
end
