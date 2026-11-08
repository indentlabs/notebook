class CacheAttributeWordCountJob < ApplicationJob
  queue_as :cache

  # These fields store ids, JSON or tag lists rather than prose
  NON_PROSE_FIELD_TYPES = %w[link universe tags].freeze

  # recount_page: also recount the page this field belongs to and record its words for the day the
  #   edit was made. Edits pass it; bulk recounts of the caches (rake tasks) don't, so they don't
  #   write a word count row for every page.
  # previous_word_count: the count of the field's text before the edit, passed only when the field
  #   had no cached count yet (fields last saved before counts were cached).
  def perform(attribute_id, recount_page: false, previous_word_count: nil)
    attribute = Attribute.includes(:attribute_field).find_by(id: attribute_id)

    # If the attribute has been deleted since this job was enqueued, just bail.
    # (Deleting it queues a recount of its page; see Attribute#recount_page_after_removal.)
    return if attribute.nil?

    word_count = word_count_for(attribute)
    # The cache still holds the count from before this edit (or from before any edits this job
    # hasn't seen yet; it reads the field's current text, so it covers those too).
    words_before = attribute.word_count_cache || previous_word_count || word_count
    attribute.update_column(:word_count_cache, word_count) unless attribute.word_count_cache == word_count

    # The page total is only recounted after this field's own count is up to date. When the two
    # jobs were queued side by side, a page total summed before the field was recounted missed the
    # words just written, and they were credited to whichever day the page was saved next.
    if recount_page && (entity = attribute.entity)
      CacheSumAttributeWordCountJob.new.save_daily_word_count_changes(
        entity,
        edited_at:     enqueued_at || Time.current,
        words_changed: word_count - words_before
      )
    end
  end

  private

  def word_count_for(attribute)
    return 0 if attribute.value.blank?
    return 0 if NON_PROSE_FIELD_TYPES.include?(attribute.attribute_field&.field_type)

    WordCountService.count_with_fallback(attribute.value)
  end
end
