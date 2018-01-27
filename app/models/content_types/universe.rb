##
# = u-ni-verse
# == /'yoone,vers/
#
# 1. a particular sphere of activity, interest, or experience
#
#    contains all canonically-related content created by Users
class Universe < ActiveRecord::Base
  acts_as_paranoid

  include HasAttributes
  include HasPrivacy
  include HasImageUploads
  include HasChangelog

  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'UniverseCoreContentAuthorizer'

  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  Rails.application.config.content_types[:all_non_universe].each do |content_type|
    has_many content_types.name.downcase.pluralize.to_sym
  end

  has_many :contributors, dependent: :destroy

  scope :is_public, -> { where(privacy: 'public') }

  after_destroy do
    Rails.application.config.content_types[:all_non_universe].each do |content_type|
      content_type.where(universe_id: self.id).update_all(universe_id: nil)
    end
  end

  def content_count
    content.count
  end

  def self.color
    'purple'
  end

  def self.icon
    'public'
  end

  def self.content_name
    'universe'
  end
end
