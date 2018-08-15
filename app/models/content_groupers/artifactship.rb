class Artifactship < ApplicationRecord
  include HasContentLinking

  belongs_to :user

  belongs_to :religion
  belongs_to :artifact, class_name: 'Item'
end
