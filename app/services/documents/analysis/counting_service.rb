module Documents
  module Analysis
    # TODO: This might not be the best name/location for this logic, but...
    #       it's what we've got for now.
    class CountingService < Service
      def self.analyze(analysis_id)
        analysis = DocumentAnalysis.find(analysis_id)
        document = analysis.document

        # Length counters
        analysis.word_count      = document.words.count
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
        analysis.words_per_sentence  = document.sentences.map { |sentence| sentence.split(' ').count }

        # Ensure we save or else throw an exception
        analysis.save!
      end
    end
  end
end
