class DocumentAnalysisJob < ApplicationJob
  queue_as :analysis

  def perform(*args)
    analysis_id = args.shift

    analysis = DocumentAnalysis.find(analysis_id)
    return unless analysis.present?

    # Start the analysis!
    Documents::Analysis::CountingService.analyze(analysis.id)
    Documents::Analysis::ReadbilityService.analyze(analysis.id)
    

    analysis.update(completed_at: DateTime.current)
  end
end
