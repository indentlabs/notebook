class DocumentEntity < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :document_analysis

  after_create :match_notebook_page!

  # TODO should this be some chain of method aliases maybe? or cached on object?
  def document_owner
    document_analysis.document.user
  end

  def match_notebook_page!
    matched_entity = document_owner.send(entity_relation).detect do |entity|
      entity_match?(entity)
    end

    # If we found a Notebook.ai entity to match to, hurrah!
    if matched_entity.present?
      update(
        entity_type: matched_entity.class.name,
        entity_id:   matched_entity.id
      )
    end

    # Return true/false for whether we found a match
    matched_entity.present?
  end

  def entity_relation
    # 'Character' => 'characters'
    self.entity_type.downcase.pluralize
  end

  def entity_match?(entity)
    return unless entity.respond_to?(:name)

    # TODO: levenshtein distance threshold comparison?
    entity.name == self.text
  end

  def dominant_emotion
    emotions.sort_by { |emotion, score| score }.reverse
  end

  def recessive_emotion
    emotions.sort_by { |emotion, score| score }
  end

  def emotions
    {
      sadness: sadness_score,
      joy: joy_score,
      fear: fear_score,
      disgust: disgust_score,
      anger: anger_score
    }
  end
end
