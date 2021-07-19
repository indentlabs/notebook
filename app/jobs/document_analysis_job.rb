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

    puts "Analyzing: Content"
    Documents::Analysis::ContentService.analyze(analysis.id)
    analysis.update(progress: 60)

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

    # Create a notification letting the user know!
    analysis.document.user.notifications.create(
      message_html:     "<div>An analysis of <span class='#{Document.text_color}'>#{analysis.document.title}</span> is ready to view.</div>",
      icon:             Document.icon,
      icon_color:       Document.color,
      happened_at:      DateTime.current,
      passthrough_link: Rails.application.routes.url_helpers.analysis_document_url(analysis.document)
    )
  end
end
