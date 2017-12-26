class Language < ActiveRecord::Base
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  include BelongsToUniverse

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

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

  def self.content_name
    'language'
  end

  def deleted_at
    nil #hack
  end
end
