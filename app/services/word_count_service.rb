# The one definition of a "word" used everywhere the app counts words: documents, notebook pages,
# timeline events, books and analyses.
#
# The document editor and the notebook page editor show live counts with a JavaScript port of this
# class (app/assets/javascripts/word_count.js). Both are tested against the same cases in
# test/fixtures/files/word_count_cases.json, so keep them in step: a change here needs the same
# change there, and a new case in that file.
#
# A word is a run of text between whitespace that contains at least one letter or digit, in any
# script. On top of that:
# - HTML is stripped. Block-level tags and <br> separate words, the way they separate lines on
#   screen; inline tags like <b> and <span> don't, so "Hel<b>lo</b>" is one word. The contents of
#   <script> and <style> elements are dropped.
# - HTML entities are decoded, so &nbsp; separates words and &amp; or &mdash; are not words.
# - Em dashes, ellipses ("…", "..." and longer) and runs of two or more hyphens separate words.
# - Forward slashes and backslashes split words (path/to/file is 3 words), except in dates
#   (01/02/2024) and links (https://example.com/a/b), which are one word each.
# - Punctuation on its own (!, &, *, ---, ___, * * *) and emoji are not words.
# - Contractions (don't), hyphenated words (well-known) and numbers (1,000 or 3.5) are one word.
#
# This is a single linear pass over the text, so it is cheap enough to run on whole novels.
class WordCountService
  BLOCK_TAG = %r{<\/?(?:address|article|aside|blockquote|br|caption|dd|details|div|dl|dt|figcaption|figure|footer|h[1-6]|header|hr|li|main|nav|ol|p|pre|section|summary|table|tbody|td|tfoot|th|thead|tr|ul)\b[^<>]*>}i
  HIDDEN_ELEMENT = %r{<(script|style)\b[^<>]*>.*?<\/\1\s*>}im
  COMMENT = /<!--.*?-->/m
  # A tag starts with a letter right after the "<", so plain text like "I <3 you" or "a < b" keeps its words.
  ANY_TAG = %r{<[\/!]?[a-zA-Z][^<>]*>}

  ENTITY = /&(#\d{1,7}|#x[0-9a-f]{1,6}|[a-z][a-z0-9]{1,31});/i
  # Entities that change how words are split or what counts as a word. Any other named entity is a
  # single character that can't add or remove a word boundary (é, ©), so it is simply dropped.
  NAMED_ENTITIES = {
    'nbsp' => "\u00A0", 'ensp' => "\u2002", 'emsp' => "\u2003", 'thinsp' => "\u2009",
    'amp' => '&', 'lt' => '<', 'gt' => '>', 'quot' => '"', 'apos' => "'",
    'mdash' => "\u2014", 'ndash' => "\u2013", 'hellip' => "\u2026",
    'lsquo' => "\u2018", 'rsquo' => "\u2019", 'sbquo' => "\u201A",
    'ldquo' => "\u201C", 'rdquo' => "\u201D", 'bdquo' => "\u201E"
  }.freeze

  SEPARATOR = /[\u2014\u2015\u2026]|\.{2,}|-{2,}/
  WHITESPACE = '\s\u00A0\u1680\u180E\u2000-\u200B\u2028\u2029\u202F\u205F\u3000\uFEFF'.freeze
  TOKEN = /[^#{WHITESPACE}]+/
  WORDLIKE = /[\p{L}\p{N}]/
  SLASHES = %r{[\/\\]}
  LINK = %r{\A[^\p{L}\p{N}]*(?:(?:https?|ftp):\/\/|www\.)}i
  DATE = %r{\A\d{1,4}\/\d{1,2}(?:\/\d{1,4})?\z}
  EDGE_PUNCTUATION = /\A[^\p{L}\p{N}]+|[^\p{L}\p{N}]+\z/

  # @param text [String, nil] HTML or plain text
  # @return [Integer] the number of words in it
  def self.count(text)
    return 0 if text.nil?

    words = 0
    plain_text(text).scan(TOKEN) { |token| words += words_in_token(token) }
    words
  end

  # Background jobs use this so a bad string can't fail them; counting shouldn't raise anyway.
  def self.count_with_fallback(text)
    count(text)
  rescue => e
    Rails.logger.warn("WordCountService: fallback to simple count: #{e.message}")
    simple_count(text)
  end

  # The text a reader would see, with word-separating markup turned into spaces.
  def self.plain_text(text)
    text = text.to_s
    text = text.dup.force_encoding(Encoding::UTF_8) unless text.encoding == Encoding::UTF_8
    text = text.scrub(' ') unless text.valid_encoding?

    if text.include?('<')
      text = text.gsub(HIDDEN_ELEMENT, ' ').gsub(COMMENT, ' ').gsub(BLOCK_TAG, ' ').gsub(ANY_TAG, '')
    end
    text = text.gsub(ENTITY) { decode_entity(Regexp.last_match(1)) } if text.include?('&')

    text.gsub(SEPARATOR, ' ')
  end

  class << self
    private

    def words_in_token(token)
      return 0 unless token.match?(WORDLIKE)
      return 1 unless token.match?(SLASHES)
      return 1 if token.match?(LINK)
      return 1 if token.gsub(EDGE_PUNCTUATION, '').match?(DATE)

      token.split(SLASHES).count { |part| part.match?(WORDLIKE) }
    end

    def decode_entity(name)
      return NAMED_ENTITIES.fetch(name.downcase, '') unless name.start_with?('#')

      codepoint = name[1].casecmp?('x') ? name[2..].to_i(16) : name[1..].to_i
      return '' if codepoint.zero? || codepoint > 0x10FFFF || (0xD800..0xDFFF).cover?(codepoint)

      [codepoint].pack('U')
    end

    def simple_count(text)
      return 0 if text.blank?
      text.gsub(/<[^>]*>/, ' ').split.size
    end
  end
end
