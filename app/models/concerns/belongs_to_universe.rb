require 'active_support/concern'

module BelongsToUniverse
  extend ActiveSupport::Concern

  included do
    belongs_to :universe, optional: true

    validate :universe_is_available_to_owner, if: :will_save_change_to_universe_id?

    scope :in_universe, ->(universe = nil) { where(universe: universe) unless universe.nil? }
  end

  # A page can only go in a universe its owner owns or contributes to
  def can_move_to_universe?(new_universe_id)
    return true if new_universe_id.to_i.zero?
    return false if user.nil?

    Universe.where(id: new_universe_id, user_id: user_id).exists? || user.contributable_universe_ids.include?(new_universe_id.to_i)
  end

  private

  def universe_is_available_to_owner
    errors.add(:universe, "isn't one you can add to") unless can_move_to_universe?(universe_id)
  end
end
