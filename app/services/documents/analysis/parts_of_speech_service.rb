module Documents
  module Analysis
    class PartsOfSpeechService < Service
      def self.analyze(analysis_id)
        analysis = DocumentAnalysis.find(analysis_id)
        document = analysis.document

        analysis.adjective_count   = document.adjectives.count
        analysis.noun_count        = document.nouns.count
        analysis.verb_count        = document.verbs.count
        analysis.pronoun_count     = document.pronouns.count
        analysis.preposition_count = document.prepositions.count
        analysis.conjunction_count = document.conjunctions.count
        analysis.adverb_count      = document.adverbs.count
        analysis.determiner_count  = document.determiners.count

        analysis.save!
      end
    end
  end
end
