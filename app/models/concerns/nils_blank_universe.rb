require 'active_support/concern'

# Model will set its Universe attribute to nil if the string is blank
module NilsBlankUniverse
  extend ActiveSupport::Concern

  included do
    before_save :nil_blank_universe
  end

  def nil_blank_universe
    universe = nil if universe.blank?
  end
end
