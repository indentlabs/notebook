module Documents
  module Analysis
    module ThirdParty
      class IbmWatsonService < Service
        def self.analyze(analysis_id)
          analysis = DocumentAnalysis.find(analysis_id)
          document = analysis.document

          # Authorize a client to analyze with
          watson_client = IBMWatson::NaturalLanguageUnderstandingV1.new(
            iam_apikey: ENV['WATSON_API_KEY'],
            version:    '2018-03-16'
          )

          # Fetch a bunch of raw results to analyze
          watson = watson_client.analyze(
            text:     document.body,
            features: {
              "entities":   {},
              "sentiment":  {},
              "categories": {},
              "concepts":   {}
            }
          )

          require 'pry'
          binding.pry

          # Language detection
          analysis.language = watson.language
          # TODO we might need to handle things very, very differently for non-en?

          # Overall sentiment of the document
          analysis.sentiment_score = watson.sentiment.document.score
          analysis.sentiment_label = watson.sentiment.document.label

          # Entity parsing!
          # "entities": [
          #   {
          #     "type": "Person",
          #     "text": "Bruce Banner",
          #     "relevance": 0.930407,
          #     "count": 3
          #   },
          #   {
          #     "type": "Person",
          #     "text": "Wayne",
          #     "relevance": 0.28717,
          #     "count": 1
          #   }
          # ]
          analysis.document_entities = []
          watson.entities.each do |entity|
            # TODO is this committing to the DB every loop? can we build all then save instead?
            analysis.document_entities.create(
              entity_type: entity_type_map_to_notebook_entity_type.fetch(entity.type, entity.type)
              entity_id:   nil,
              text:        entity.text,
              relevance:   entity.relevance
            ) if entity_type_map_to_notebook_entity_type.keys.include?(entity.type)
          end

          # Concept parsing
          # "concepts": [
          #   {
          #     "text": "Jeph Loeb",
          #     "relevance": 0.964521,
          #     "dbpedia_resource": "http://dbpedia.org/resource/Jeph_Loeb"
          #   },
          analysis.document_concepts = []
          watson.concepts.each do |concept|
            analysis.document_concepts.create(
              text:           concept.text,
              relevance:      concept.relevance,
              reference_link: concept.dbpedia_resource
            )
          end

          # Category parsing
          # "categories": [
          #   {
          #     "score": 0.982925,
          #     "label": "/art and entertainment/comics and animation/comics"
          #   }
          # ]
          analysis.document_categories = []
          watson.categories.each do |category|
            analysis.document_categories.create(
              label: category.label,
              score: category.score
            )
          end

        end

        def self.entity_type_map_to_notebook_entity_type
          {
            'Person' => 'Character'
          }
        end
      end
    end
  end
end
