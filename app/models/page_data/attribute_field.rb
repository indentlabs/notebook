class AttributeField < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true

  belongs_to :user
  belongs_to :attribute_category
  has_many :attribute_values, class_name: 'Attribute', dependent: :destroy

  has_many :page_references, dependent: :destroy

  validates_presence_of :user_id

  acts_as_list scope: [:user_id, :attribute_category_id]

  include HasAttributes
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  attr_accessor :system

  before_validation :ensure_name

  UNDELETEABLE_FIELD_TYPES = %w(name universe tags)
  SETTABLE_FIELD_TYPES     = %w(text_area page_link)

  # Who can see this field (and its values) on pages that use it:
  # - public:       anyone who can view the page
  # - contributors: the page owner, the universe owner, and contributors to the containing universe
  # - private:      only the page owner
  VISIBILITIES = {
    'public'       => 'Everyone who can view the page',
    'contributors' => 'Universe contributors only',
    'private'      => 'Only me'
  }.freeze

  validates :privacy, inclusion: { in: VISIBILITIES.keys }

  # todo replace old_column_source etc
  #json :acceptable_page_link_classes

  def self.color
    'amber'
  end

  def self.text_color
    'amber-text'
  end

  def self.icon
    'text_fields'
  end

  # Icon used for a specific attribute field
  def icon
    case self.field_type
    when 'name'
      'fingerprint'
    when 'link'
      'link'
    when 'universe'
      Universe.icon
    when 'textarea'
      'text_fields'
    when 'tags'
      'label'
    else
      'text_fields'
    end
  end

  def self.content_name
    'attribute'
  end

  def humanize
    label
  end

  def private?
    effective_privacy != 'public'
  end

  # The privacy level actually in effect for this field. Legacy Private Notes
  # fields (old_column_source == 'private_notes') have always been hidden from
  # other viewers, so they can be opened up to contributors but never made fully
  # public -- for everything else the privacy column is authoritative.
  def effective_privacy
    return privacy if VISIBILITIES.key?(privacy) && privacy != 'public'
    return 'private' if old_column_source == 'private_notes'

    'public'
  end

  # Legacy Private Notes fields can't be made fully public (see effective_privacy)
  def can_be_public?
    old_column_source != 'private_notes'
  end

  def system?
    !!self.system
  end

  def name_field?
    self.field_type == 'name'
  end

  def universe_field?
    self.field_type == 'universe'
  end

  def tags_field?
    self.field_type == 'tags'
  end

  private

  def ensure_name
    self.name ||= "#{label}-#{Time.now.to_i}".underscore.gsub(' ', '_')
  end
end
