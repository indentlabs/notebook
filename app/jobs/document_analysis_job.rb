class DocumentAnalysisJob < ApplicationJob
  queue_as :analysis

  def perform(*args)
    analysis_id = args.shift

    analysis = DocumentAnalysis.find(analysis_id)
    return unless analysis.present?

    # Start the analysis!
    Documents::Analysis::CountingService.analyze(analysis.document_id)


    # Do something later
    require 'pry'
    binding.pry
  end
end
