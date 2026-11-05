##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ApplicationRecord
  acts_as_paranoid

  include IsContentPage
  # include HasContent # can't do this because we generate cycles since HasContent relies on Universe already being initialized

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'UniverseCoreContentAuthorizer'

  validates :name,    presence: true
  validates :user_id, presence: true

  belongs_to :user
  # The following doesn't work because Rails.application.config isn't initialized yet
  # Rails.application.config.content_types[:all_non_universe].each do |content_type|
  #   has_many content_types.name.downcase.pluralize.to_sym
  # end
  has_many :characters
  has_many :countries
  has_many :creatures
  has_many :deities
  has_many :floras
  has_many :governments
  has_many :groups
  has_many :items
  has_many :landmarks
  has_many :languages
  has_many :locations
  has_many :magics
  has_many :planets
  has_many :races
  has_many :religions
  has_many :scenes
  has_many :technologies
  has_many :towns
  has_many :vehicles
  has_many :conditions
  has_many :buildings
  has_many :jobs
  has_many :traditions
  has_many :sports
  has_many :schools
  has_many :foods
  has_many :continents
  has_many :lores

  has_many :contributors, dependent: :destroy
  has_many :contributing_users, through: :contributors, source: :user

  has_many :books
  has_many :documents
  has_many :timelines

  scope :in_universe, ->(universe = nil) { where(id: universe.try(:id)) unless universe.nil? }

  # Whether this viewer sees everything in the universe, private and password protected pages included
  def viewable_in_full_by?(viewer)
    return false unless viewer.present? && viewer.id.present?

    viewer.site_administrator? || user_id == viewer.id || contributors.exists?(user_id: viewer.id)
  end

  # Anyone who can see a public universe can see its documents, except password protected ones.
  # A private or password protected universe passes nothing on, so only public documents show.
  def documents_listable_by(viewer)
    return documents if viewable_in_full_by?(viewer)
    return documents.without_passwords_unless_owned_by(viewer) if privacy == 'public'

    documents.public_or_owned_by(viewer)
  end

  # One kind of thing in this universe (e.g. :characters, :books or :timelines) as this viewer can see
  # it listed. Members see everything; everyone else sees what's public on its own or through the
  # universe, which leaves out password protected pages and everything in a universe that isn't public.
  def pages_listable_by(viewer, relation)
    pages = public_send(relation)
    viewable_in_full_by?(viewer) ? pages : pages.is_public
  end

  after_destroy do
    Rails.application.config.content_types[:all_non_universe].each do |content_type|
      content_type.where(universe_id: self.id).update_all(universe_id: nil)
    end
  end

  def description
    overview_field_value('Description')
  end

  def content_count
    content.count
  end

  def self.color
    'purple bg-purple-800'
  end

  def self.text_color
    'purple-text text-purple-800'
  end

  def self.hex_color
    '#9C27B0'
  end

  def self.icon
    'language'
  end

  def self.content_name
    'universe'
  end
  
  def content
    # This is a worse version of the HasContent #content, but... dunno how to include
    # that functionality in this class without duplicating it in two places and hard-coding
    # the other content type names. TODO come back and fix this
    content = {}
    Rails.application.config.content_types[:all_non_universe].each do |content_type|
      content[content_type.name] = send(content_type.name.downcase.pluralize)
    end

    content
  end
end
