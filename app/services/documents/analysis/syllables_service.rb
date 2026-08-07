module Documents
  module Analysis
    class SyllablesService < Service
      SYLLABLE_COUNT_OVERRIDES = {
        'ion' => 2
      }

      def self.count(word)
        word = word.downcase.gsub(/[^a-z]/, '')

        # Overrides must win before the short-word shortcut ("ion" is 2 syllables)
        return SYLLABLE_COUNT_OVERRIDES[word] if SYLLABLE_COUNT_OVERRIDES.key?(word)
        return 1 if word.length <= 3

        word = word.sub(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '').sub(/^y/, '')
        count = word.scan(/[aeiouy]+/).length
        count > 0 ? count : 1
      end
    end
  end
end
