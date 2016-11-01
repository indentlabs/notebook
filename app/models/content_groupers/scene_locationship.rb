class SceneLocationship < ActiveRecord::Base
  belongs_to :user

  belongs_to :scene
  belongs_to :scene_location, class_name: 'Location'
end