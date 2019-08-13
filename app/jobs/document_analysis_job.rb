class DocumentAnalysisJob < ApplicationJob
  queue_as :analysis

  def perform(*args)
    analysis_id = args.shift

    analysis = DocumentAnalysis.find(analysis_id)
    return unless analysis.present?

    # Start the analysis!
    puts "Analysing: Counts"
    Documents::Analysis::CountingService.analyze(analysis.id)
    analysis.update(progress: 25)

    puts "Analysing: Readability"
    Documents::Analysis::ReadabilityService.analyze(analysis.id)
    analysis.update(progress: 50)

    puts "Analysing: Parts of Speech"
    Documents::Analysis::PartsOfSpeechService.analyze(analysis.id)
    analysis.update(progress: 75)

    puts "IBM Watson's Analysis"
    Documents::Analysis::ThirdParty::IbmWatsonService.analyze(analysis.id)
    analysis.update(progress: 100)

    # TODO:
    # - Sentiment analysis
    # - Character appearance analysis
    # - Typo analysis
    # - Gotcha analysis

    analysis.update(completed_at: DateTime.current)
  end
end
