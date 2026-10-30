require 'active_support/concern'

module HasParseableText
  extend ActiveSupport::Concern

  included do
    def plaintext(line_length = 80, from_charset = 'UTF-8')
      @plaintext ||= Documents::PlaintextService.from_html(self.body, line_length, from_charset)
    end

    def characters
      @characters ||= plaintext.chars
    end

    def paragraphs
      @paragraphs ||= begin
        # Normalize text
        ## We use paragraph tags by default, but people might paste in divs also
        paragraphed_sanity = ActionController::Base.helpers.sanitize(body, tags: %w(div p), attributes: %w())
        if paragraphed_sanity.nil?
          paragraphs = []
        else
          paragraphed_sanity.gsub!('<div></div>', '')
          paragraphed_sanity.gsub!('<p></p>', '')
          
          paragraphs =  paragraphed_sanity.scan(/<p>[^<]+<\/p>/).map {     |text| ActionView::Base.full_sanitizer.sanitize(text) }
          paragraphs << paragraphed_sanity.scan(/<div>[^<]+<\/div>/).map { |text| ActionView::Base.full_sanitizer.sanitize(text) }
        end
      end.flatten
    end

    def sentences
      @sentences ||= sentences_with_newlines.map { |sentence| sentence.gsub("\n", ' ') }
    end

    def sentences_with_newlines
      @sentences_with_newlines ||= plaintext(line_length=Float::INFINITY).scan(/[^\.!?]+[\.!?]+/)
    end

    def words
      @words ||= begin
        text = plaintext.downcase

        # Split on forward slashes (matches WordCountService behavior)
        # Preserve dates like 01/02/2024 by temporarily replacing them
        text = text.gsub(/(\d{1,2})\/(\d{1,2})(\/\d{2,4})?/) { |m| m.gsub('/', '-SLASH-') }
        text = text.gsub('/', ' ')
        text = text.gsub('-SLASH-', '/')

        # Split on backslashes
        text = text.gsub('\\', ' ')

        # Remove dotted lines, dashed lines, underscores (standalone)
        text = text.gsub(/\.{2,}/, ' ')  # ... or ....
        text = text.gsub(/-{2,}/, ' ')   # -- or ---
        text = text.gsub(/_{2,}/, ' ')   # __ or ___

        # Remove non-word characters except apostrophes (for contractions)
        text = text.gsub(/[^\s\w\d']/, '')

        # Split on whitespace and filter empty strings
        text.split(/\s+/).reject(&:blank?)
      end
    end

    def pages
      # todo this might make more sense as a word count splitter instead of lines?
      @pages ||= plaintext.split("\n").each_slice(Documents::PlaintextService::PLAINTEXT_LINES_PER_PAGE)
    end

    def acronyms
      @acroynyms ||= words
        .select { |word| word == word.upcase && word.length > 1 && !is_numeric?(word) }
        .uniq
        .sort
    end

    # As defined by Robert Gunning in the GFI and SMOG
    def complex_words
      @complex_words ||= unique_words.select { |word| Documents::Analysis::SyllablesService.count(word) >= 3 }
    end

    def simple_words
      @simple_words ||= unique_words - complex_words
    end

    def unique_words
      words.map(&:downcase).uniq
    end

    def words_with_syllables syllable_count
      words.select { |word| Documents::Analysis::SyllablesService.count(word) == syllable_count }
    end

    def word_syllables
      words.map { |word| Documents::Analysis::SyllablesService.count(word) }
    end

    def is_numeric?(string)
      true if Float(string) rescue false
    end
  end
end
