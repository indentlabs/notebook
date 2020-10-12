class AddReadabilityMetricsToDocumentAnalysis < ActiveRecord::Migration[6.0]
  def change
    add_column :document_analyses, :linsear_write_grade, :float
    add_column :document_analyses, :dale_chall_grade, :float

    add_column :document_analyses, :unique_complex_words_count, :integer
    add_column :document_analyses, :unique_simple_words_count, :integer

    add_column :document_analyses, :hate_content_flag,       :boolean, default: false
    add_column :document_analyses, :hate_trigger_words,      :string
    add_column :document_analyses, :profanity_content_flag,  :boolean, default: false
    add_column :document_analyses, :profanity_trigger_words, :string
    add_column :document_analyses, :sex_content_flag,        :boolean, default: false
    add_column :document_analyses, :sex_trigger_words,       :string
    add_column :document_analyses, :violence_content_flag,   :boolean, default: false
    add_column :document_analyses, :violence_trigger_words,  :string
    add_column :document_analyses, :adult_content_flag,      :boolean, default: false
  end
end
