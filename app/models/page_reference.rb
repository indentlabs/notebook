class PageReference < ApplicationRecord
  belongs_to :referencing_page, polymorphic: true
  belongs_to :referenced_page, polymorphic: true
  belongs_to :attribute_field
end
