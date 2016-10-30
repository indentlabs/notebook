class Language < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  scope :is_public, -> { eager_load(:universe).where('languages.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def description
    num_speakers = Lingualism.where(spoken_language_id: id).count
    "Language spoken by #{ActionController::Base.helpers.pluralize num_speakers, 'character'}"
  end

  def self.color
    'blue'
  end

  def self.icon
    'forum'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name other_names universe_id)
      },
      info: {
        icon: 'forum',
        attributes: %w(history typology dialectical_information register)
      },
      phonology: {
        icon: 'speaker_notes',
        attributes: %w(phonology)
      },
      grammar: {
        icon: 'list',
        attributes: %w(grammar)
      },
      entities: {
        icon: 'settings_input_component',
        attributes: %w(numbers quantifiers)
      },
      # lexicon: {
      #   icon: 'info',
      #   attributes: %w()
      # },
      # spoken_by: {
      #   icon: 'info',
      #   attributes: %w()
      # },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
