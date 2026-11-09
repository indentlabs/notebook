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
      recount.call(Document.with_deleted, 'Documents') { |document| WordCountService.count_with_fallback(document.body) }
    end

    if only.include?('revisions')
      recount.call(DocumentRevision.with_deleted, 'Revisions') { |revision| WordCountService.count_with_fallback(revision.body) }
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

        recount.call(klass.unscoped, type) do |page|
          Attribute.where(entity_type: type, entity_id: page.id).sum(:word_count_cache)
        end
      end
    end
  end

  # From Oct 30, 2026 until the fix, each document's revision job ran once after a deploy and then
  # never again (the debounce lock never expired), so later writing got no daily word count row and
  # no revision. This gives each such document:
  # - a word count row on the day it was last saved, counting what was written since its last
  #   revision (all of it on that day, since when each word was written wasn't recorded), and
  # - a revision of its text as last saved, so the next revision's "Show Changes" shows only what
  #   is written after that, not the stuck period's writing as new.
  # Run it once, soon after deploying the fix. Documents edited since the deploy are skipped.
  #
  #   rake word_counts:recover_stuck_lock_writing                 # dry run: report only
  #   rake word_counts:recover_stuck_lock_writing DRY_RUN=false
  desc "Recover writing that the stuck document job lock never recorded (DRY_RUN=false to write)"
  task recover_stuck_lock_writing: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    since = Time.zone.parse(ENV['SINCE'] || '2026-10-30 00:00 UTC')
    recovered_rows = 0
    recovered_revisions = 0

    puts dry_run ? '=== DRY RUN (DRY_RUN=false to write) ===' : '=== RECOVERING ==='

    Document.where('updated_at >= ?', since).where.not(user_id: nil).includes(:user).find_each(batch_size: 200) do |document|
      newest = document.document_revisions.order(updated_at: :desc, id: :desc).first
      # Saved since its last revision (by more than one debounce window). A document edited since the
      # fix has a revision from then, so it is skipped.
      next unless newest.nil? || newest.updated_at < document.updated_at - 1.minute

      body = document.body.to_s
      words_now = WordCountService.count_with_fallback(body)
      words_at_last_revision = newest ? WordCountService.count_with_fallback(newest.body) : 0
      last_saved_on = WordCountUpdate.date_for(document.user, document.updated_at)
      row = document.word_count_updates.find_by(for_date: last_saved_on)

      if row.nil? || row.starting_word_count.nil?
        recovered_rows += 1
        unless dry_run
          if row
            row.convert_to_starting_count!(words_at_last_revision)
            row.update!(word_count: words_now)
          else
            WordCountUpdate.record!(document, date: last_saved_on, word_count: words_now) { words_at_last_revision }
          end
        end
      end

      recovered_revisions += 1
      next if dry_run

      document.document_revisions.where(closed_at: nil).update_all(closed_at: document.updated_at)
      document.document_revisions.create!(
        title: document.title, body: body, synopsis: document.synopsis, universe_id: document.universe_id,
        notes_text: document.notes_text, cached_word_count: words_now,
        created_at: document.updated_at, updated_at: document.updated_at, closed_at: document.updated_at
      )
    end

    puts "#{recovered_rows} word count rows #{dry_run ? 'would be' : ''} recorded, " \
         "#{recovered_revisions} revisions #{dry_run ? 'would be' : ''} added".squeeze(' ')
  end
end
