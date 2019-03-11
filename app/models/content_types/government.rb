class Government < ApplicationRecord
  acts_as_paranoid

  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true

  include BelongsToUniverse
  include IsContentPage
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'ExtendedContentAuthorizer'

  relates :leaders,           with: :government_leaders
  relates :groups,            with: :government_groups
  relates :political_figures, with: :government_political_figures
  relates :items,             with: :government_items
  relates :technologies,      with: :government_technologies
  relates :creatures,         with: :government_creatures

  def description
    overview_field_value('Description')
  end

  def self.color
    'darken-2 green'
  end

  def self.hex_color
    '#388E3C'
  end

  def self.icon
    'account_balance'
  end

  def self.content_name
    'government'
  end
end
