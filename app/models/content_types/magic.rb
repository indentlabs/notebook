class Magic < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :deities, with: :magic_deityships

  scope :is_public, -> { eager_load(:universe).where('magics.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'orange'
  end

  def self.icon
    'flash_on'
  end

  def self.content_name
    'magic'
  end
end
