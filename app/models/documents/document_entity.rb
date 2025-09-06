class DocumentEntity < ApplicationRecord
  belongs_to :entity, polymorphic: true, optional: true
  belongs_to :document_analysis, optional: true
  has_one :document, through: :document_analysis

  after_create :match_notebook_page!, if: Proc.new { |de| de.entity_id.nil? }

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

  # Analyze this entity within the context of an existing document analysis
  # AKA this entity was probably added manuallly post-analysis
  def analyze!
    DocumentEntityAnalysisJob.perform_later(id)
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

  def linked_name_if_possible
    entity.present? ? entity.name : text
  end

  def dominant_emotion
    return { unknown: 1 } if emotions.values.uniq == [0]

    emotions.sort_by { |emotion, score| score }.reverse
  end

  def recessive_emotion
    return { unknown: 1 } if emotions.values.uniq == [0]

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
