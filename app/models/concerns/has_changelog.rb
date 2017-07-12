require 'active_support/concern'

module HasChangelog
  extend ActiveSupport::Concern

  included do
    def change_events
      ContentChangeEvent.where(content_id: id, content_type: self.class.name).order(:id)
    end

    after_create do
      ContentChangeEvent.create(
        user:           user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :created
      )
    end

    after_update do
      ContentChangeEvent.create(
        user:           user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :updated
      ) if changes.any?
    end

    before_destroy do
      ContentChangeEvent.create(
        user:           user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :deleted
      )
    end
  end
end
