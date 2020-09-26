module Documents
  module Analysis
    class ContentService < Service
      def self.analyze(analysis_id)
        analysis = DocumentAnalysis.find(analysis_id)
        document = analysis.document
        
        analysis.hate_trigger_words      = LanguageFilter::Filter.new(matchlist: :hate, replacement: :stars).matched(document.plaintext)
        analysis.hate_content_flag       = analysis.hate_trigger_words.any?

        analysis.profanity_trigger_words = LanguageFilter::Filter.new(matchlist: :profanity, replacement: :stars).matched(document.plaintext)
        analysis.profanity_content_flag  = analysis.profanity_trigger_words.any?

        analysis.sex_trigger_words       = LanguageFilter::Filter.new(matchlist: :sex, replacement: :stars).matched(document.plaintext)
        analysis.sex_content_flag        = analysis.sex_trigger_words.any?

        analysis.violence_trigger_words  = LanguageFilter::Filter.new(matchlist: :violence, replacement: :stars).matched(document.plaintext)
        analysis.violence_content_flag   = analysis.violence_trigger_words.any? 

        analysis.adult_content_flag = analysis.hate_content_flag? || analysis.profanity_content_flag? || analysis.sex_content_flag? || analysis.violence_content_flag?

        analysis.save!
      end

      def self.adult_content?(matchlist=:hate, content)
        LanguageFilter::Filter.new(matchlist: matchlist).matched(content)
      end
    end
  end
end
