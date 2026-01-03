module Documents
  module Analysis
    # TODO: This might not be the best name/location for this logic, but...
    #       it's what we've got for now.
    class CountingService < Service
      def self.analyze(analysis_id)
        analysis = DocumentAnalysis.find(analysis_id)
        document = analysis.document

        # Length counters
        # Use WordCountService for consistent word counting across the app
        analysis.word_count      = WordCountService.count(document.body)
        analysis.page_count      = document.pages.count
        analysis.paragraph_count = document.paragraphs.count
        analysis.character_count = document.characters.count
        analysis.sentence_count  = document.sentences.count

        # Syllable counting -- needs audit on memory/speed, could be hugely optimized
        analysis.n_syllable_words = Hash[(1..20).map do |syllable_count|
          [syllable_count, document.words_with_syllables(syllable_count).count]
        end].reject { |syllables, count| count.zero? }

        # Word reuse -- there's probably a WAY better way to compute this, but
        # I guess speed isn't priority #1 when you're async anyway. We should
        # definitely audit memory usage here though.
        analysis.words_used_repeatedly_count = document.words
            .select { |word| document.words.rindex(word) != document.words.index(word) }
            .uniq
            .count

        analysis.words_used_once_count = analysis.word_count - analysis.words_used_repeatedly_count

        # Complexity counters
        analysis.complex_words_count = document.words.select { |word| document.complex_words.include?(word) }.count
        analysis.simple_words_count  = document.words.select { |word| document.simple_words.include?(word) }.count
        analysis.unique_complex_words_count = document.complex_words.count
        analysis.unique_simple_words_count  = document.simple_words.count
        analysis.words_per_sentence  = document.sentences.map { |sentence| sentence.split(' ').count }

        # Frequency tables
        analysis.most_used_words      = document.non_stop_words(with_duplicates: true).group_by(&:itself).transform_values!(&:size).sort_by(&:second).last(10).reverse
        analysis.most_used_adjectives = document.adjectives.reject { |word, count| I18n.t('stop-words').include?(word) }.sort_by(&:second).last(10).reverse
        analysis.most_used_nouns      = document.nouns.reject { |word, count| I18n.t('stop-words').include?(word) }.sort_by(&:second).last(10).reverse
        analysis.most_used_verbs      = document.verbs.reject { |word, count| I18n.t('stop-words').include?(word) }.sort_by(&:second).last(10).reverse
        analysis.most_used_adverbs    = document.adverbs.reject { |word, count| I18n.t('stop-words').include?(word) }.sort_by(&:second).last(10).reverse

        # Ensure we save or else throw an exception
        analysis.save!
      end
    end
  end
end
