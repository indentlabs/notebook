class CacheAttributeWordCountJob < ApplicationJob
  queue_as :cache

  # These fields store ids, JSON or tag lists rather than prose
  NON_PROSE_FIELD_TYPES = %w[link universe tags].freeze

  # recount_page: also recount the page this field belongs to and record its words for the day the
  #   edit was made. Edits pass it; bulk recounts of the caches (rake tasks) don't, so they don't
  #   write a word count row for every page.
  # previous_word_count: the count of the field's text from before the edit, by the current
  #   counter (see Attribute#enqueue_word_count_jobs).
  def perform(attribute_id, recount_page: false, previous_word_count: nil)
    attribute = Attribute.includes(:attribute_field).find_by(id: attribute_id)

    # If the attribute has been deleted since this job was enqueued, just bail.
    # (Deleting it queues a recount of its page; see Attribute#recount_page_after_removal.)
    return if attribute.nil?

    word_count = word_count_for(attribute)
    cached_before = attribute.word_count_cache
    attribute.update_column(:word_count_cache, word_count) unless cached_before == word_count
    return unless recount_page && (entity = attribute.entity)

    if cached_before == word_count
      # Nothing new to count: an earlier job already counted this text (it reads the field's current
      # text, so it covered later edits too), or the edit didn't change the count.
      words_changed = 0
      recount = 0
    else
      words_before = previous_word_count || cached_before || word_count
      words_changed = word_count - words_before
      # The page's totals so far included this field at its cached count. If that differs from its
      # old text counted the current way (no cached count yet, or one made by an older counter),
      # that difference is a recount, not writing.
      recount = words_before - cached_before.to_i
    end

    # The page total is only recounted after this field's own count is up to date. When the two
    # jobs were queued side by side, a page total summed before the field was recounted missed the
    # words just written, and they were credited to whichever day the page was saved next.
    CacheSumAttributeWordCountJob.new.save_daily_word_count_changes(
      entity,
      edited_at:     enqueued_at || Time.current,
      words_changed: words_changed,
      recount:       recount
    )
  end

  private

  def word_count_for(attribute)
    return 0 if attribute.value.blank?
    return 0 if NON_PROSE_FIELD_TYPES.include?(attribute.attribute_field&.field_type)

    WordCountService.count(attribute.value)
  end
end
