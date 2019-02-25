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
      @paragraphs ||= plaintext.split(/[\r\n\t]+/)
    end

    def sentences
      @sentences ||= plaintext.strip.split(/[!\?\.]/)
    end

    def words
      @words ||= plaintext.downcase.gsub(/[^\s\w']/, '').split(' ').reject { |w| is_numeric?(w) }
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
