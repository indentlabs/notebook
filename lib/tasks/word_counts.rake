namespace :word_counts do
  # The counter changed in November 2026 (see WordCountService). Counts stored before then were made
  # the old ways (the document editor's count dropped about one word per paragraph), so lists,
  # cards and the revision history's "+N words" disagree with new counts until each page is edited.
  # This recounts the stored counts without writing any word_count_updates rows, so nothing is
  # credited as written. Safe to run while people are writing; re-running only repeats the work.
  #
  #   rake word_counts:recount_cached                       # everything
  #   rake word_counts:recount_cached ONLY=documents,revisions,pages
  desc "Recount cached word counts with the current counter, crediting nothing"
  task recount_cached: :environment do
    only = ENV['ONLY'].to_s.split(',').map(&:strip).presence || %w[documents revisions pages]
    batch_size = (ENV['BATCH_SIZE'] || 500).to_i

    recount = lambda do |relation, label, &count|
      changed = 0
      relation.find_each(batch_size: batch_size).with_index(1) do |record, index|
        new_count = count.call(record)
        if record.cached_word_count != new_count
          record.update_column(:cached_word_count, new_count)
          changed += 1
        end
        puts "#{label}: #{index} checked, #{changed} recounted" if (index % 10_000).zero?
      end
      puts "#{label}: done, #{changed} recounted"
    end

    if only.include?('documents')
      recount.call(Document.with_deleted, 'Documents') { |document| WordCountService.count(document.body) }
    end

    if only.include?('revisions')
      recount.call(DocumentRevision.with_deleted, 'Revisions') { |revision| WordCountService.count(revision.body) }
    end

    if only.include?('pages')
      checked = 0
      Attribute.find_each(batch_size: batch_size) do |attribute|
        # Same rules as edits (link, universe and tags fields count 0), without touching the page's rows
        CacheAttributeWordCountJob.perform_now(attribute.id)
        checked += 1
        puts "Fields: #{checked} recounted" if (checked % 50_000).zero?
      end
      puts "Fields: done, #{checked} recounted"

      types = Rails.application.config.content_types[:all].map(&:name) + %w[Universe]
      types.uniq.each do |type|
        klass = type.safe_constantize
        next unless klass&.column_names&.include?('cached_word_count')

        recount.call(klass.unscoped.includes(:user), type) do |page|
          total = Attribute.where(entity_type: type, entity_id: page.id).sum(:word_count_cache)

          # If the page was edited today, today started from the old total: move the start by the
          # recount too, so it isn't credited as writing by the page's next edit
          difference = total - page.cached_word_count.to_i
          today = page.word_count_updates.find_by(for_date: WordCountUpdate.date_for(page.user)) unless difference.zero?
          today&.update!(starting_word_count: today.starting_count + difference, word_count: today.word_count.to_i + difference)

          total
        end
      end
    end
  end

  # From Oct 30, 2026 until the fix, each document's word count job ran once after a deploy and then
  # never again (the debounce lock never expired), so writing saved after that got no daily word count
  # row. A document's next save records that writing on the day it was last saved (see
  # Document#record_untracked_writing!). This does the same for documents nobody has saved since, so
  # their November writing counts towards goals too. Safe to run more than once.
  #
  #   rake word_counts:recover_untracked_writing                 # dry run: report only
  #   rake word_counts:recover_untracked_writing DRY_RUN=false
  desc "Record writing the stuck document job lock never counted (DRY_RUN=false to write)"
  task recover_untracked_writing: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    since = Time.zone.parse(ENV['SINCE'] || '2026-10-30 00:00 UTC')
    candidates = 0
    recorded = 0

    puts dry_run ? '=== DRY RUN (DRY_RUN=false to write) ===' : '=== RECORDING ==='

    Document.where('updated_at >= ?', since).where.not(user_id: nil).includes(:user).find_each(batch_size: 200) do |document|
      # Saved on a day with no row: its job never ran that day
      next if document.word_count_updates.exists?(for_date: WordCountUpdate.date_for(document.user, document.updated_at))

      candidates += 1
      next if dry_run

      recorded += 1 if document.record_untracked_writing!(saved_at: document.updated_at, word_count: WordCountService.count(document.body))
    end

    puts dry_run ? "#{candidates} documents were last saved on a day with no word count row" : "Recorded untracked writing for #{recorded} of #{candidates} documents"
  end
end
