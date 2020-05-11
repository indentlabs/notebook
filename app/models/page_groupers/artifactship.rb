class Artifactship < ApplicationRecord
  include HasContentLinking

  belongs_to :user, optional: true

  belongs_to :religion
  belongs_to :artifact, class_name: 'Item', optional: true
end
