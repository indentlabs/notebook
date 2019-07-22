require 'active_support/concern'

module HasParseableText
  extend ActiveSupport::Concern

  included do
    def plaintext
      @plaintext ||= Documents::PlaintextService.from_html(self.body)
    end

    def characters
      @characters ||= plaintext.chars
    end

    def paragraphs
      @paragraphs ||= begin
        # Normalize text
        ## We use paragraph tags by default, but people might paste in divs also
        paragraphed_sanity = ActionController::Base.helpers.sanitize(body, :tags => %w(div p))
        paragraphed_sanity.gsub!('<div></div>', '')
        paragraphed_sanity.gsub!('<p></p>', '')
        
        paragraphs =  paragraphed_sanity.scan(/<p>[^<]+<\/p>/).map {     |text| ActionView::Base.full_sanitizer.sanitize(text) }
        paragraphs << paragraphed_sanity.scan(/<div>[^<]+<\/div>/).map { |text| ActionView::Base.full_sanitizer.sanitize(text) }
      end.flatten
    end

    def sentences
      @sentences ||= plaintext.strip.split(/[!\?\.]/).reject(&:empty?).map { |sentence| sentence.gsub("\n", ' ') }
    end

    def words
      @words ||= plaintext.downcase.gsub(/[^\s\w']/, '').split(' ').reject { |w| is_numeric?(w) }
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
