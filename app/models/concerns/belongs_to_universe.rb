require 'active_support/concern'

module BelongsToUniverse
  extend ActiveSupport::Concern

  included do
    belongs_to :universe

    scope :in_universe, ->(universe = nil) { where(universe: universe) unless universe.nil? }
  end
end
