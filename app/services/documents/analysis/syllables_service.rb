module Documents
  module Analysis
    class SyllablesService < Service
      SYLLABLE_COUNT_OVERRIDES = {
        'ion' => 2
      }

      def self.count(word)
        word.downcase.gsub!(/[^a-z]/, '')

        return 1 if word.length <= 3
        return SYLLABLE_COUNT_OVERRIDES[word] if SYLLABLE_COUNT_OVERRIDES.key?(word)

        word.sub(/(?:[^laeiouy]es|ed|[^laeiouy]e)$/, '').sub!(/^y/, '')
        word.scan(/[aeiouy]{1,2}/).length
      end
    end
  end
end
