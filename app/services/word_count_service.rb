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
#
# For large documents (>300KB), uses a memory-efficient lightweight counter
# to avoid the ~28MB peak memory usage of the WordCountAnalyzer gem.
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

  # ~50k words threshold (300KB assumes ~6 bytes per word average)
  LARGE_TEXT_THRESHOLD = 300_000
  CHUNK_SIZE = 100_000

  # Count words in the given text using standardized rules.
  # Uses the WordCountAnalyzer gem for small documents and a lightweight
  # counter for large documents to reduce memory usage.
  #
  # @param text [String] The text to count words in (may contain HTML)
  # @return [Integer] The word count
  def self.count(text)
    return 0 if text.blank?

    if text.bytesize < LARGE_TEXT_THRESHOLD
      WordCountAnalyzer::Counter.new(**COUNTER_OPTIONS).count(text)
    else
      count_large_text(text)
    end
  end

  # Count words with fallback to simple counting on error.
  # Use this in background jobs where reliability is more important than
  # perfect accuracy.
  #
  # @param text [String] The text to count words in (may contain HTML)
  # @return [Integer] The word count
  def self.count_with_fallback(text)
    count(text)
  rescue => e
    Rails.logger.warn("WordCountService: fallback to simple count: #{e.message}")
    simple_count(text)
  end

  class << self
    private

    def count_large_text(text)
      cleaned = text.gsub(/<[^>]*>/, ' ')  # Strip HTML

      if cleaned.bytesize > CHUNK_SIZE * 3
        count_chunked(cleaned)
      else
        count_single_pass(cleaned)
      end
    end

    def count_single_pass(text)
      count = 0
      scanner = StringScanner.new(text)

      while !scanner.eos?
        scanner.skip(/\s+/)
        token = scanner.scan(/\S+/)
        break unless token
        count += count_token(token)
      end

      count
    end

    def count_chunked(text)
      total = 0
      offset = 0

      while offset < text.length
        chunk_end = [offset + CHUNK_SIZE, text.length].min

        # Find word boundary to avoid splitting words
        if chunk_end < text.length
          while chunk_end > offset && !text[chunk_end].match?(/\s/)
            chunk_end -= 1
          end
          chunk_end = offset + CHUNK_SIZE if chunk_end == offset
        end

        total += count_single_pass(text[offset...chunk_end])
        offset = chunk_end
      end

      total
    end

    def count_token(token)
      return 0 if token.match?(/\A\.{3,}\z/)      # Ellipsis
      return 0 if token.match?(/\A-{2,}\z/)       # Dashed line
      return 0 if token.match?(/\A_{2,}\z/)       # Underscore line
      return 0 if token.match?(/\A[^\w]+\z/)      # Stray punctuation

      if token.include?('/')
        return 1 if token.match?(/\A\d{1,2}\/\d{1,2}(\/\d{2,4})?\z/)  # Date
        return token.split('/').reject(&:empty?).size
      end

      if token.include?('\\')
        return token.split('\\').reject(&:empty?).size
      end

      1  # Contractions and hyphenated words count as one
    end

    def simple_count(text)
      return 0 if text.blank?
      text.gsub(/<[^>]*>/, ' ').split.size
    end
  end
end
