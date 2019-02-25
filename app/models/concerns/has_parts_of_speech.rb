require 'active_support/concern'

module HasPartsOfSpeech
  extend ActiveSupport::Concern

  included do
    def adjectives
      @adjectives ||= words.select { |word| word.category == 'adjective' }.uniq
    end

    def adverbs
      @adverbs ||= words.select { |word| word.category == 'adverb' }.uniq
    end

    def conjunctions
      @conjunctions ||= words.select { |word| word.category == 'conjunction' }.uniq
    end

    def determiners
      @determiners ||= words.select { |word| word.category == 'determiner' }.uniq
    end

    def nouns
      @nouns ||= words.select { |word| word.category == 'noun' }.uniq
    end

    def numbers
      @numbers ||= text.strip
        .split(' ')
        .select { |w| is_numeric?(w) }
        .uniq
    end

    def prepositions
      @prepositions ||= words.select { |word| word.category == 'preposition' }.uniq
    end

    def pronouns
      @pronouns ||= words.select { |word| I18n.t('pronouns').include? word }.uniq
    end

    def stop_words
      words.select { |word| I18n.t('stop-words').include? word }.uniq
    end

    def verbs
      @verbs ||= words.select { |word| word.category == 'verb' }.uniq
    end

    def unrecognized_words
      @unrecognized_words ||= words.select { |word| word.category == 'unknown' }.uniq - pronouns
    end
  end
end
