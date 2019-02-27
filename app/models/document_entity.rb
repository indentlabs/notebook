class DocumentEntity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :document_analysis

  after_create :match_notebook_page

  def match_notebook_page
    # TODO: Attempt to link to a Notebook.ai page of the same name
  end
end
