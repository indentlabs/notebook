class AttributeCategory < ApplicationRecord
  acts_as_paranoid

  validates :name, presence: true
  # validates :entity_type, presence: true # todo turn this on, but check prod data for exceptions first

  belongs_to :user
  has_many   :attribute_fields, dependent: :destroy

  include HasAttributes
  include Serendipitous::Concern

  include Authority::Abilities
  self.authorizer_name = 'AttributeAuthorizer'

  acts_as_list scope: [:user_id, :entity_type]

  before_validation :ensure_name

  SPECIAL_CATEGORY_LABELS = %w(Settings Contributors Gallery Changelog)
  scope :shown_on_template_editor, -> { where.not(label: SPECIAL_CATEGORY_LABELS) }

  def self.color
    'amber'
  end

  def self.text_color
    'amber-text'
  end

  def icon
    icon_override || self.class.icon
  end

  def self.icon
    'folder_open'
  end

  def self.content_name
    'attribute_category'
  end

  def icon
    self['icon'] || self.class.icon
  end

  def entity_class
    entity_type.titleize.constantize
  end

  def backfill_categories_ordering!
    content_type_class = entity_type.titleize.constantize
    category_owner = User.with_deleted.find_by(id: user_id)

    categories = content_type_class.attribute_categories(category_owner, show_hidden: true).to_a

    ActiveRecord::Base.transaction do
      categories.each.with_index do |content_to_order, index|
        content_to_order.update_column(:position, 1 + index) if content_to_order.persisted?

        # While we're doing this, we might as well backfill the fields also
        content_to_order.backfill_fields_ordering!
      end
    end
  end

  def backfill_fields_ordering!
    sorted_fields = attribute_fields.select(&:persisted?).sort do |a, b|
      # TODO: we shouldn't need this code anymore
      a_value = case a.field_type
        when 'name'     then 0
        when 'universe' then 1
        else 2 # 'text_area', 'link'
      end

      b_value = case b.field_type
        when 'name'     then 0
        when 'universe' then 1
        else 2
      end

      if a.position && b.position
        a.position <=> b.position
      else
        a_value <=> b_value
      end
    end

    ActiveRecord::Base.transaction do
      sorted_fields.each.with_index do |content_to_order, index|
        content_to_order.update_column(:position, 1 + index) if content_to_order.persisted?
      end
    end
  end

  private

  def ensure_name
    self.name ||= "#{label}-#{Time.now.to_i}".underscore.gsub(' ', '_')
  end
end
