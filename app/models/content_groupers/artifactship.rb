class Artifactship < ActiveRecord::Base
  belongs_to :user

  belongs_to :religion
  belongs_to :artifact, class_name: 'Item'
end