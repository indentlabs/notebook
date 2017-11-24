require 'active_support/concern'

module HasChangelog
  extend ActiveSupport::Concern

  included do
    def change_events
      ContentChangeEvent.where(content_id: id, content_type: self.class.name).order(:id)
    end

    after_create do
      ContentChangeEvent.create(
        user:           find_current_user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :created
      )
    end

    after_update do
      # todo how to get current_user?
      ContentChangeEvent.create(
        user:           find_current_user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :updated
      ) if changes.any?
    end

    before_destroy do
      ContentChangeEvent.create(
        user:           find_current_user,
        changed_fields: changes,
        content_id:     id,
        content_type:   self.class.name,
        action:         :deleted
      )
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
