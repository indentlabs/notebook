module Documents
  module Analysis
    module ThirdParty
      class IbmWatsonService < Service
        def self.analyze(analysis_id)
          analysis = ::DocumentAnalysis.find(analysis_id)
          document = analysis.document

          watson_client = new_client

          # Fetch a bunch of raw results to analyze
          watson = watson_client.analyze(
            html:     document.body,
            features: {
              "entities":   {
                "sentiment": true, # this allows us to skip the sentiment call later if we don't care about calculating sentiment on entities we don't care about also
                "emotion":   true  # see https://console.bluemix.net/apidocs/natural-language-understanding ctrl+f entities.emotion
              },
              "categories": {},
              "concepts":   {
                "limit": 10
              },
              "sentiment":  {},
              "emotion":    {}
            }
          ).result

          # Language detection
          analysis.language = watson.dig('language')

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
          watson.fetch('entities', []).each do |entity|
            analysis.document_entities.build(
              entity_type:     entity_type_map_to_notebook_entity_type.fetch(entity.dig('type'), entity.dig('type')),
              text:            entity.dig('text'),
              relevance:       entity.dig('relevance'),
              sentiment_label: entity.dig('sentiment', 'label'),
              sentiment_score: entity.dig('sentiment', 'score'),
              sadness_score:   entity.dig('emotion', 'sadness'),
              joy_score:       entity.dig('emotion', 'joy'),
              fear_score:      entity.dig('emotion', 'fear'),
              disgust_score:   entity.dig('emotion', 'disgust'),
              anger_score:     entity.dig('emotion', 'anger')
            ) if should_save_entity?(entity)
          end

          # Concept parsing
          # "concepts": [
          #   {
          #     "text": "Jeph Loeb",
          #     "relevance": 0.964521,
          #     "dbpedia_resource": "http://dbpedia.org/resource/Jeph_Loeb"
          #   },
          analysis.document_concepts = []
          watson.fetch('concepts', []).each do |concept|
            analysis.document_concepts.build(
              text:           concept.dig('text'),
              relevance:      concept.dig('relevance'),
              reference_link: concept.dig('dbpedia_resource')
            ) if should_save_concept?(concept)
          end

          # Category parsing
          # "categories": [
          #   {
          #     "score": 0.982925,
          #     "label": "/art and entertainment/comics and animation/comics"
          #   }
          # ]
          analysis.document_categories = []
          watson.fetch('categories', []).each do |category|
            analysis.document_categories.build(
              label: category.dig('label'),
              score: category.dig('score')
            ) if should_save_category?(category)
          end

          # Overall sentiment of the document
          analysis.sentiment_score = watson.dig('sentiment', 'document', 'score')
          analysis.sentiment_label = watson.dig('sentiment', 'document', 'label')

          # Emotional analysis
          analysis.joy_score     = watson.dig('emotion', 'document', 'emotion', 'joy')
          analysis.sadness_score = watson.dig('emotion', 'document', 'emotion', 'sadness')
          analysis.fear_score    = watson.dig('emotion', 'document', 'emotion', 'fear')
          analysis.disgust_score = watson.dig('emotion', 'document', 'emotion', 'disgust')
          analysis.anger_score   = watson.dig('emotion', 'document', 'emotion', 'anger')

          # Throw an exception if this can't save so we can 1) retry, and 2) see fails in logs
          analysis.save!
        end

        # This re-analyzes a specific entity within a document, useful for manually adding entities post-analysis
        def self.analyze_entity(document_entity)
          watson_client = new_client

          entity = ::DocumentEntity.find(document_entity.to_i) # raises unless found :+1:
          analysis = entity.document_analysis
          document = analysis.document

          # Fetch a bunch of raw results to analyze
          watson = watson_client.analyze(
            html:     document.body,
            features: {
              "entities": {
                "targets": [
                  entity.text
                ]
              },
              "sentiment":  {
                "targets": [
                  entity.text
                ]
              },
              "emotion": {
                "targets": [
                  entity.text
                ]
              }
            }
          ).result

          entity_sentiment_block = (watson.dig('sentiment', 'targets').presence || {}).detect { |target| target['text'] == entity.text }.presence || {}
          entity_emotion_block   = (watson.dig('emotion',   'targets').presence || {}).detect { |target| target['text'] == entity.text }.presence || {}
          entity.update!(
            relevance:       1.00, # todo we should figure something out here, uh oh
            sentiment_label: entity_sentiment_block.dig('label')            || 'Unknown',
            sentiment_score: entity_sentiment_block.dig('score')            || 0,
            sadness_score:   entity_emotion_block.dig('emotion', 'sadness') || 0,
            joy_score:       entity_emotion_block.dig('emotion', 'joy')     || 0,
            fear_score:      entity_emotion_block.dig('emotion', 'fear')    || 0,
            disgust_score:   entity_emotion_block.dig('emotion', 'disgust') || 0,
            anger_score:     entity_emotion_block.dig('emotion', 'anger')   || 0
          )
        end

        private

        def self.entity_type_map_to_notebook_entity_type
          # todo we can probably also build Towns from location disambiguations, e.g. 
          #    {"type"=>"Location", "text"=>"Bendal", "relevance"=>0.159735, "disambiguation"=>{"subtype"=>["City"]}, "count"=>2},
          {
            'Person'       => Character.name,
            'Organization' => Group.name,
            'Company'      => Group.name, # todo actual Company pages?
            'Location'     => Location.name,
            'JobTitle'     => Job.name,
            'Facility'     => Building.name
          }
        end

        def self.should_save_entity?(entity)
          [
            entity_type_map_to_notebook_entity_type.keys.include?(entity.dig('type')),
            entity.dig('relevance') >= 0.3
          ].all?
        end

        def self.should_save_concept?(concept)
          concept.key?('relevance') && concept.dig('relevance') >= 0.3
        end

        def self.should_save_category?(category)
          category.key?('score') && category.dig('score') >= 0.3
        end

        def self.new_client
          IBMWatson::NaturalLanguageUnderstandingV1.new(
            version: "2018-03-16",
            authenticator: IBMWatson::Authenticators::IamAuthenticator.new(
              apikey: ENV['WATSON_API_KEY']
            )
          )
        end
      end
    end
  end
end
