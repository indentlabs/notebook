# Centralized word counting service that provides consistent word counts
# across the entire application (Ruby and JavaScript should match this behavior).
#
# Uses the WordCountAnalyzer gem with specific settings to ensure:
# - Forward slashes split words (path/to/file = 3 words), except in dates
# - Backslashes split words (path\to\file = 3 words)
# - Dotted lines (...) are ignored
# - Dashed lines (---) are ignored
# - Underscores (___) are ignored
# - Stray punctuation is ignored
# - Contractions count as one word (don't = 1 word)
# - Hyphenated words count as one word (well-known = 1 word)
# - Numbers are counted as words
# - HTML/XHTML is stripped before counting
class WordCountService
  COUNTER_OPTIONS = {
    ellipsis:          'ignore',
    hyperlink:         'count_as_one',
    contraction:       'count_as_one',
    hyphenated_word:   'count_as_one',
    date:              'no_special_treatment',
    number:            'count',
    numbered_list:     'ignore',
    xhtml:             'remove',
    forward_slash:     'count_as_multiple_except_dates',
    backslash:         'count_as_multiple',
    dotted_line:       'ignore',
    dashed_line:       'ignore',
    underscore:        'ignore',
    stray_punctuation: 'ignore'
  }.freeze

  # Count words in the given text using standardized rules.
  #
  # @param text [String] The text to count words in (may contain HTML)
  # @return [Integer] The word count
  def self.count(text)
    return 0 if text.blank?

    WordCountAnalyzer::Counter.new(**COUNTER_OPTIONS).count(text)
  end
end
