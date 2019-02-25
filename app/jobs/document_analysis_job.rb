class DocumentAnalysisJob < ApplicationJob
  queue_as :analysis

  def perform(*args)
    analysis_id = args.shift

    analysis = DocumentAnalysis.find(analysis_id)
    return unless analysis.present?

    # Start the analysis!
    Documents::Analysis::CountingService.analyze(analysis.id)
    Documents::Analysis::ReadabilityService.analyze(analysis.id)
    Documents::Analysis::PartsOfSpeechService.analyze(analysis.id)

    # TODO:
    # - Sentiment analysis
    # - Character appearance analysis
    # - Typo analysis
    # - Gotcha analysis

    analysis.update(completed_at: DateTime.current)
  end
end
