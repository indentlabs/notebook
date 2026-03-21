require 'active_support/concern'

module IsContentPage
  extend ActiveSupport::Concern

  included do
    include HasAttributes
    include HasPrivacy
    include HasContentGroupers
    include HasImageUploads
    include HasChangelog
    include HasPageTags
    include HasPageReferences

    has_many :content_page_shares,         as: :content_page, dependent: :destroy
    has_many :page_collection_submissions, as: :content,      dependent: :destroy
    has_many :timeline_event_entities,     as: :entity,       dependent: :destroy
    has_many :timeline_events,             through: :timeline_event_entities
    has_many :timelines, -> { distinct },  through: :timeline_events

    has_many :basil_commissions,           as: :entity, dependent: :destroy

    has_many :word_count_updates, as: :entity, dependent: :destroy
    def latest_word_count_cache
      word_count_updates.order('for_date DESC').limit(1).first.try(:word_count) ||  0
    end

    scope :unarchived, -> { where(archived_at: nil) }
    def archive!
      update!(archived_at: DateTime.now)
    end
    def unarchive!
      update!(archived_at: nil)
    end
    def archived?
      !archived_at.nil?
    end

    has_many :document_entities, as: :entity
    attr_accessor :document_entity_id
    def documents
      if self.is_a?(Universe)
        # Universes are treated separately since documents actually have a universe_id now
        Document.where(universe_id: self.id)

      else
        # For all other content pages, we have to fetch document IDs off DocumentEntities that
        # match those content pages
        document_ids = ::DocumentAnalysis.where(
          id: document_entities.pluck(:document_analysis_id)
        ).pluck(:document_id)
        Document.where(id: document_ids)
      end
    end

    def self.settings_override_for(user)
      return nil # disabled for now
      return nil if user.nil?
      return nil unless user.on_premium_plan?

      # todo technically we could cache a has_page_overrides on User to skip a lot of unncessessary lookups here
      user.page_settings_overrides.find_by(page_type: self.name.downcase)
    end

    def self.name_for(user)
      settings_override_for(user).try(:name_override).presence || self.name
    end

    def self.icon_for(user)
      settings_override_for(user).try(:icon_override).presence || self.icon
    end

    def self.hex_color_for(user)
      settings_override_for(user).try(:hex_color_override).presence || self.hex_color
    end

    # def self.color_for(user)
    #   if user.nil?
    #     self.color
    #   elsif user.on_premium_plan?
    #     color = user.content_page_setting_overrides.find_by(page_type: self.class.name).try(:color)
    #     color.presence || self.color
    #   else
    #     self.color
    #   end
    # end

    # Instance methods that delegate to class methods
    # This allows templates to call content_page.color instead of content_page.class.color
    def color
      self.class.color
    end

    def text_color
      self.class.text_color
    end

    def icon
      self.class.icon
    end
  end
end
