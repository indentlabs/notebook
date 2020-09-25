module Documents
  module Analysis
    class ReadabilityService < Service
      def self.analyze(analysis_id)
        analysis = DocumentAnalysis.find(analysis_id)
        document = analysis.document

        analysis.flesch_kincaid_grade_level     = FleschKincaidService.grade_level(document)
        analysis.flesch_kincaid_age_minimum     = FleschKincaidService.age_minimum(document)
        analysis.flesch_kincaid_reading_ease    = FleschKincaidService.reading_ease(document)

        analysis.forcast_grade_level            = self.forcast_grade_level(document)
        analysis.coleman_liau_index             = self.coleman_liau_index(document)
        analysis.automated_readability_index    = self.automated_readability_index(document)
        analysis.gunning_fog_index              = self.gunning_fog_index(document)
        analysis.smog_grade                     = self.smog_grade(document)
        analysis.linsear_write_grade            = self.linsear_write_grade(document)
        # todo clamp/scale these from 0..16?

        analysis.combined_average_reading_level = self.combined_average_grade_level(analysis)
        analysis.readability_score              = self.readability_score(analysis)

        analysis.save!
      end

      def self.forcast_grade_level(document)
        @forcast_grade_level ||= 20 - (((document.words_with_syllables(1).length.to_f / document.words.length) * 150) / 10.0).clamp(0, 16)
      end

      def self.coleman_liau_index(document)
        @coleman_liau_index ||= [
          0.0588 * 100 * document.characters.reject { |l| [" ", "\t", "\r", "\n"].include?(l) }.length.to_f / document.words.length,
          -0.296 * 100/ (document.words.length.to_f / document.sentences.length),
          -15.8
        ].sum.clamp(0, 16)
      end

      def self.automated_readability_index(document)
        @automated_readability_index ||= [
          4.71 * document.characters.reject(&:blank?).length.to_f / document.words.length,
          0.5 * document.words.length.to_f / document.sentences.length,
          -21.43
        ].sum.clamp(0, 16)
      end

      def self.gunning_fog_index(document)
        #todo GFI word/suffix exclusions
        @gunning_fog_index ||= 0.4 * (document.words.length.to_f/ document.sentences.length + 100 * (document.complex_words.length.to_f / document.words.length)).clamp(0, 16)
      end

      def self.smog_grade(document)
        @smog_grade ||= 1.043 * Math.sqrt(document.complex_words.length.to_f * (30.0 / document.sentences.length)) + 3.1291
      end

      def self.linsear_write_grade(document)
        @linsear_write_grade ||= TextStat.linsear_write_formula(document.plaintext)
      end

      def self.combined_average_grade_level(analysis)
        # TODO need to normalize all these scores to 1..16
        # TODO need to exclude scores here that aren't actually grade level output?
        readability_scores = [
          analysis.automated_readability_index, # todo this is an age that needs converted to grade level
          analysis.coleman_liau_index,
          analysis.flesch_kincaid_grade_level,
          analysis.forcast_grade_level,
          analysis.gunning_fog_index,
          analysis.smog_grade
        ]

        readability_scores.reject! &:nil?
        readability_scores.select! { |value| value.is_a?(Numeric) }
        readability_scores.reject! { |hasselhoff| hasselhoff.abs == Float::INFINITY }

        return nil unless readability_scores.compact.length > 2
        (readability_scores.compact.sort.slice(1..-2).sum.to_f / 4).clamp(0, 16)
      end

      def self.readability_score(analysis)
        # TODO need to normalize all these scores to 0..100
        readability_scores = [
          analysis.coleman_liau_index,
          analysis.flesch_kincaid_reading_ease,
          analysis.forcast_grade_level,
          analysis.gunning_fog_index,
          analysis.smog_grade
        ]

        readability_scores.reject! &:nil?
        readability_scores.select! { |value| value.is_a?(Numeric) }
        readability_scores.reject! { |hasselhoff| hasselhoff.abs == Float::INFINITY }

        return nil unless readability_scores.compact.length > 2
        (100 - readability_scores.compact.sort.slice(1..-2).sum.to_f / 4).clamp(0, 100)
      end

      def self.readability_score_category(score)
        case score
        when 0..35
          return 'Hard'
        when 36..65
          return 'Average'
        when 66..100
          return 'Easy'
        end
      end

      def self.readability_score_text(analysis)
        category = self.readability_score_category(analysis.readability_score)

        case category
        when 'Easy'
          [
            "Nice!",
            "This document is easily understandable by readers with at least a",
            analysis.combined_average_reading_level.round.ordinalize,
            "grade reading level."
          ].join(' ')
        when 'Average'
          [
            "Not bad!",
            "This document is understandable by readers with at least a",
            analysis.combined_average_reading_level.round.ordinalize,
            "grade reading level."
          ].join(' ')
        when 'Hard'
          [
            "This document is mostly understandable by readers with at least a",
            analysis.combined_average_reading_level.round.ordinalize,
            "grade reading level.",
            "It could definitely be improved!"
          ].join(' ')
        end
      end

    end
  end
end
