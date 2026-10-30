namespace :wordsmith do
  desc "Download the pinned dictionary/thesaurus/rhyming data and (re)build the Wordsmith reference table"
  task import: :environment do
    sources = Wordsmith::Sources.new
    puts "Fetching Wordsmith sources into #{sources.directory}..."
    sources.fetch!

    started = Time.current
    count = Wordsmith::Importer.new(**sources.importer_options, logger: Logger.new($stdout)).import!
    puts "Imported #{count} Wordsmith entries in #{(Time.current - started).round}s."
  end
end
