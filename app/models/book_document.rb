class BookDocument < ApplicationRecord
  acts_as_list scope: :book_id

  belongs_to :book, touch: true
  belongs_to :document

  validates :document_id, uniqueness: { scope: :book_id, message: 'is already in this book' }
end
