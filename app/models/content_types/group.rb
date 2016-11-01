class Group < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

  include HasAttributes
  include HasPrivacy
  include HasContentGroupers
  include Serendipitous::Concern

  # Characters
  relates :leaders, with: :group_leaderships

  # Groups
  relates :supergroups, with: :supergroupships
  relates :subgroups, with: :subgroupships
  relates :sistergroups, with: :sistergroupships
  relates :allies, with: :group_allyships
  relates :enemies, with: :group_enemyships
  relates :rivals, with: :group_rivalships
  relates :clients, with: :group_clientships
  relates :suppliers, with: :group_supplierships

  # Locations
  relates :headquarters, with: :headquarterships
  relates :offices, with: :officeships

  # Items
  relates :equipment, with: :group_equipmentships
  relates :key_items, with: :key_itemships

  scope :is_public, -> { eager_load(:universe).where('groups.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'cyan'
  end

  def self.icon
    'wc'
  end

  def self.content_name
    'group'
  end
end
