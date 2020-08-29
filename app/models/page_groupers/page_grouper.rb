class PageGrouper < ApplicationRecord
  self.abstract_class = true

  include HasContentLinking

  belongs_to :user, optional: true
end