class Group < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :user
  validates :user_id, presence: true

  belongs_to :universe

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

  scope :is_public, -> { eager_load(:universe).where('creatures.privacy = ? OR universes.privacy = ?', 'public', 'public') }

  def self.color
    'cyan'
  end

  def self.icon
    'wc'
  end

  def self.attribute_categories
    {
      overview: {
        icon: 'info',
        attributes: %w(name description other_names universe_id)
      },
      hierarchy: {
        icon: 'call_split',
        attributes: %w(organization_structure leaders supergroups subgroups sistergroups)
      },
      location: {
        icon: 'location_on',
        attributes: %w(headquarters offices)
      },
      purpose: {
        icon: 'business',
        attributes: %w(motivation goal obstacles risks)
      },
      politics: {
        icon: 'thumbs_up_down',
        attributes: %w(allies enemies rivals clients)
      },
      inventory: {
        icon: 'shopping_cart',
        attributes: %w(inventory equipment key_items suppliers)
      },
      notes: {
        icon: 'edit',
        attributes: %w(notes private_notes)
      }
    }
  end
end
