class CacheAttributeWordCountJob < ApplicationJob
  queue_as :cache

  def perform(*args)
    attribute_id = args.shift
    attribute    = Attribute.find_by(id: attribute_id)

    # If the attribute has been deleted since this job was enqueued, just bail
    if attribute.nil?
      return
    end

    # If we have a blank/null value, ezpz 0 words
    if attribute.nil? || attribute.value.nil? || attribute.value.blank?
      attribute.update_column(:word_count_cache, 0)
      return
    end

    # If we actually have some content, use a smart WordCountAnalyzer instead of just splitting on spaces
    word_count = WordCountAnalyzer::Counter.new(
      ellipsis:          'no_special_treatment',
      hyperlink:         'count_as_one',
      contraction:       'count_as_one',
      hyphenated_word:   'count_as_one',
      date:              'no_special_treatment',
      number:            'count',
      numbered_list:     'ignore',
      xhtml:             'remove',
      forward_slash:     'count_as_multiple_except_dates',
      backslash:         'count_as_one',
      dotted_line:       'ignore',
      dashed_line:       'ignore',
      underscore:        'ignore',
      stray_punctuation: 'ignore'
    ).count(attribute.value)

    attribute.update_column(:word_count_cache, word_count)
  end
end
