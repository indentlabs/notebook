# The one definition of a "word" used everywhere the app counts words: documents, notebook pages,
# timeline events, books and analyses.
#
# The document editor and the notebook page editor show live counts with a JavaScript port of this
# class (app/assets/javascripts/word_count.js). Both are tested against the same cases in
# test/fixtures/files/word_count_cases.json, so keep them in step: a change here needs the same
# change there, and a new case in that file.
#
# Changing a rule changes stored counts. Run `rake word_counts:recount_cached` after deploying it,
# and expect the deploy day's words to include the old-to-new difference for anyone who had already
# written that day. (Ruby and browsers can also disagree on letters added in newer Unicode versions
# than Ruby's, which no shared case can catch.)
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
# Every step takes time linear in the length of the text, malformed HTML included, so it is cheap
# enough to run on whole novels and safe to run on anything a user can type.
class WordCountService
  # A tag is "<", an ASCII name (optionally after "/" or "!") and then whitespace, "/" or ">". So
  # plain text like "I <3 you", "a < b" or an <email@example.com> keeps its words, and so does a
  # Markdown autolink like <https://example.com/page>.
  TAG = %r{\G<(?![A-Za-z][A-Za-z0-9+.\-]*://)([/!]?)([A-Za-z][A-Za-z0-9:\-]*)(?=[ \t\n\f\r/>])[^<>]*>}
  # Tags that separate words, the way they separate lines or cells on screen. Any other tag (b, i,
  # span, a, font...) is removed without a space, so "Hel<b>lo</b>" is one word.
  BLOCK_TAGS = %w[
    address article aside blockquote br caption center dd details dialog div dl dt fieldset
    figcaption figure footer form h1 h2 h3 h4 h5 h6 header hgroup hr legend li main menu nav ol p
    pre section summary table tbody td tfoot th thead tr ul
  ].to_set.freeze
  # Elements whose contents aren't shown. Unclosed, they hide the rest of the text, as in a browser.
  HIDDEN_ELEMENT_ENDS = {
    'script' => %r{</[Ss][Cc][Rr][Ii][Pp][Tt][ \t\n\f\r]*>},
    'style'  => %r{</[Ss][Tt][Yy][Ll][Ee][ \t\n\f\r]*>}
  }.freeze

  ENTITY = /&(#[0-9]{1,7}|#[xX][0-9A-Fa-f]{1,6}|[A-Za-z][A-Za-z0-9]{1,31});/
  # Named entities that split words, join them, or aren't words on their own (keys in lower case).
  NAMED_ENTITIES = {
    'nbsp' => "\u00A0", 'nonbreakingspace' => "\u00A0", 'ensp' => "\u2002", 'emsp' => "\u2003",
    'emsp13' => "\u2004", 'emsp14' => "\u2005", 'numsp' => "\u2007", 'puncsp' => "\u2008",
    'thinsp' => "\u2009", 'thinspace' => "\u2009", 'hairsp' => "\u200A", 'verythinspace' => "\u200A",
    'mediumspace' => "\u205F", 'zerowidthspace' => "\u200B", 'newline' => "\n", 'tab' => "\t",
    'amp' => '&', 'lt' => '<', 'gt' => '>', 'quot' => '"', 'apos' => "'",
    'mdash' => "\u2014", 'horbar' => "\u2015", 'ndash' => "\u2013", 'hellip' => "\u2026", 'mldr' => "\u2026",
    'lsquo' => "\u2018", 'rsquo' => "\u2019", 'sbquo' => "\u201A",
    'ldquo' => "\u201C", 'rdquo' => "\u201D", 'bdquo' => "\u201E"
  }.freeze
  # Named entities for letters (&eacute;, &szlig;, &alpha;...), which can be a whole word ("à").
  LETTER_ENTITY = /\A(?:[A-Za-z](?:acute|grave|circ|tilde|uml|ring|cedil|slash|caron|macr|ogon|dot|breve|dblac|strok)|[A-Za-z]{2}lig|szlig|eth|thorn)\z/i
  GREEK_LETTER_ENTITIES = %w[
    alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu nu xi omicron pi rho sigma
    sigmaf tau upsilon phi chi psi omega thetasym upsih piv
  ].to_set.freeze
  # Any other named entity is a symbol (&copy;, &euro;), not a word.

  SEPARATOR = /[\u2014\u2015\u2026]|\.{2,}|-{2,}/
  WHITESPACE = '\s\u00A0\u1680\u180E\u2000-\u200B\u2028\u2029\u202F\u205F\u3000\uFEFF'.freeze
  TOKEN = /[^#{WHITESPACE}]+/
  WORDLIKE = /[\p{L}\p{N}]/
  SLASHES = %r{[/\\]}
  LINK = %r{(?:[Hh][Tt][Tt][Pp][Ss]?|[Ff][Tt][Pp])://|(?:\A|[^\p{L}\p{N}])[Ww][Ww][Ww]\.}
  DATE = %r{\A[^\p{L}\p{N}]*[0-9]{1,4}/[0-9]{1,2}(?:/[0-9]{1,4})?[^\p{L}\p{N}]*\z}

  # @param text [String, nil] HTML or plain text
  # @return [Integer] the number of words in it
  def self.count(text)
    return 0 if text.nil?

    words = 0
    plain_text(text).scan(TOKEN) { |token| words += words_in_token(token) }
    words
  end

  # The text a reader would see, with word-separating markup turned into spaces.
  def self.plain_text(text)
    text = text.to_s
    text = text.dup.force_encoding(Encoding::UTF_8) unless text.encoding == Encoding::UTF_8
    text = text.scrub(' ') unless text.valid_encoding?

    text = strip_markup(text) if text.include?('<')
    text = text.gsub(ENTITY) { decode_entity(Regexp.last_match(1)) } if text.include?('&')

    text.gsub(SEPARATOR, ' ')
  end

  class << self
    private

    def words_in_token(token)
      return 0 unless token.match?(WORDLIKE)
      return 1 unless token.match?(SLASHES)
      return 1 if token.match?(LINK) || token.match?(DATE)

      token.split(SLASHES).count { |part| part.match?(WORDLIKE) }
    end

    # One pass over the text, looking at each "<" once, so even malformed HTML takes linear time.
    #
    # It works on bytes: every pattern here is ASCII, and UTF-8 never uses an ASCII byte inside a
    # multi-byte character, so these offsets always fall between characters. (On a string with any
    # non-ASCII character, Ruby finds a character offset by scanning from the start, which made this
    # quadratic on any draft with a curly quote in it.)
    def strip_markup(text)
      text = text.b
      result = String.new(encoding: Encoding::BINARY)
      position = 0

      while (open = text.index('<', position))
        result << text[position...open]

        if text[open, 4] == '<!--'
          close = text.index('-->', open + 4)
          result << ' '
          position = close ? close + 3 : text.length
        elsif (tag = TAG.match(text, open))
          name = tag[2].downcase(:ascii)
          opens_element = tag[1].empty? && !tag[0].end_with?('/>')
          hidden_end = opens_element ? HIDDEN_ELEMENT_ENDS[name] : nil

          if hidden_end
            close = hidden_end.match(text, tag.end(0))
            result << ' '
            position = close ? close.end(0) : text.length
          else
            result << ' ' if BLOCK_TAGS.include?(name)
            position = tag.end(0)
          end
        else
          result << '<'
          position = open + 1
        end
      end

      (result << text[position..]).force_encoding(Encoding::UTF_8)
    end

    def decode_entity(name)
      unless name.start_with?('#')
        lower = name.downcase(:ascii)
        return NAMED_ENTITIES[lower] if NAMED_ENTITIES.key?(lower)
        return 'a' if name.match?(LETTER_ENTITY) || GREEK_LETTER_ENTITIES.include?(lower)

        return ''
      end

      codepoint = name[1] == 'x' || name[1] == 'X' ? name[2..].to_i(16) : name[1..].to_i
      return '' if codepoint.zero? || codepoint > 0x10FFFF || (0xD800..0xDFFF).cover?(codepoint)

      [codepoint].pack('U')
    end
  end
end
