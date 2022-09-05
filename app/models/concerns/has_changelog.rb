require 'active_support/concern'

module HasChangelog
  extend ActiveSupport::Concern

  included do
    attr_accessor :disable_changelog_this_request

    def content_change_events
      ContentChangeEvent.where(
        content_id: id,
        content_type: self.class.name
      ).includes(:user).order(:id)
    end

    def attribute_change_events(limit=100)
      ContentChangeEvent.where(
        content_id: Attribute.where(
          entity_type: self.class.name,
          entity_id: id
        ),
        content_type: "Attribute"
      ).includes(:user).order(:id).last(limit)
    end

    after_create do
      if self.is_a?(Attribute)
        changes = {"value"=>[nil, value]} if changes.nil?

        ContentChangeEvent.create(
          user:           find_current_user,
          changed_fields: changes,
          content_id:     id,
          content_type:   self.class.name,
          action:         :created
        ) if changes.any? && !disable_changelog_this_request
      end
    end

    before_update do
      if self.is_a?(Attribute)
        # todo how to get current_user?

        ContentChangeEvent.create(
          user:           find_current_user,
          changed_fields: changes,
          content_id:     id,
          content_type:   self.class.name,
          action:         :updated
        ) if changes.any? && !disable_changelog_this_request
      end
    end

    before_destroy do
      if self.is_a?(Attribute)
        ContentChangeEvent.create(
          user:           find_current_user,
          changed_fields: changes,
          content_id:     id,
          content_type:   self.class.name,
          action:         :deleted
        ) if !disable_changelog_this_request
      end
    end

    private

    def find_current_user
      (1..Kernel.caller.length).each do |n|
        RubyVM::DebugInspector.open do |i|
          current_user = eval "current_user rescue nil", i.frame_binding(n)
          return current_user unless current_user.nil?
        end
      end
      return nil
    end
  end
end
