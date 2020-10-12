class DocumentRevision < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :document

  def user
    document.user
  end
end
