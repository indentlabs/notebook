require 'active_support/concern'

module HasPartsOfSpeech
  extend ActiveSupport::Concern

  included do
    def nouns
      EngTagger.new.get_nouns(tagged_text)
    end

    def proper_nouns
      EngTagger.new.get_proper_nouns(tagged_text)
    end

    def noun_phrases
      EngTagger.new.get_noun_phrases(tagged_text)
    end

    def verbs
      EngTagger.new.get_verbs(tagged_text)
    end

    def present_verbs
      EngTagger.new.get_present_verbs(tagged_text)
    end

    def infinitive_verbs
      EngTagger.new.get_infinitive_verbs(tagged_text)
    end

    def past_tense_verbs
      EngTagger.new.get_past_tense_verbs(tagged_text)
    end

    def passive_verbs
      EngTagger.new.get_passive_verbs(tagged_text)
    end

    def gerund_verbs
      EngTagger.new.get_gerund_verbs(tagged_text)
    end

    def adjectives
      EngTagger.new.get_adjectives(tagged_text)
    end

    def superlative_adjectives
      EngTagger.new.get_superlative_adjectives(tagged_text)
    end

    def comparative_adjectives
      EngTagger.new.get_comparative_adjectives(tagged_text)
    end

    def adverbs
      EngTagger.new.get_adverbs(tagged_text)
    end

    def conjunctions
      EngTagger.new.get_conjunctions(tagged_text)
    end

    def determiners
      # todo need something else
      # EngTagger.new.get_determiners(tagged_text)
    end

    def prepositions
      # todo need something else
      # EngTagger.new.get_prepositions(tagged_text)
    end

    def interrogatives
      EngTagger.new.get_interrogatives(tagged_text)
    end

    def numbers
      @numbers ||= text.strip
        .split(' ')
        .select { |w| is_numeric?(w) }
        .uniq
    end

    def pronouns
      @pronouns ||= words.select { |word| I18n.t('pronouns').include? word }.uniq
    end

    def stop_words(with_duplicates: false)
      stop_words = words.select { |word| I18n.t('stop-words').include?(word) }
      stop_words.uniq! unless with_duplicates

      stop_words
    end

    def non_stop_words(with_duplicates: false)
      non_stop_words = words.reject { |word| I18n.t('stop-words').include?(word) }
      non_stop_words.uniq! unless with_duplicates

      non_stop_words
    end
  end
end
