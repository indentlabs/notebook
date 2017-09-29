class SceneLocationship < ActiveRecord::Base
  include HasContentLinking

  belongs_to :user

  belongs_to :scene
  belongs_to :scene_location, class_name: 'Location'
end