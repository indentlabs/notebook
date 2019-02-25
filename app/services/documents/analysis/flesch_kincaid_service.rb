module Documents
  module Analysis
    class FleschKincaidService < Service
      def self.grade_level document
        @flesch_kincaid_grade_level ||= [
          0.38 * (document.words.length.to_f / document.sentences.length),
          11.18 * (document.word_syllables.sum.to_f / document.words.length),
          -15.59
        ].sum
      end

      def self.age_minimum document
        @flesch_kincaid_age_minimum ||= case reading_ease(document)
          when (100..1e5) then 11
          when (90..100)  then 11
          when (71..89)   then 12
          when (67..69)   then 13
          when (64..66)   then 14
          when (60..63)   then 15
          when (50..59)   then 18
          when (40..49)   then 21
          when (31..39)   then 24
          when (0..30)    then 25
          when (-1e5..-1) then 25
          else
        end
      end

      def self.reading_ease document
        @flesch_kincaid_reading_ease ||= [
          206.835,
          -(1.015 * document.words.length.to_f / document.sentences.length),
          -(84.6 * document.word_syllables.sum.to_f / document.words.length)
        ].sum
      end
    end
  end
end
