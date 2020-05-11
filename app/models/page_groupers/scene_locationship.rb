class SceneLocationship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :scene
  belongs_to :scene_location, class_name: 'Location', optional: true
end
