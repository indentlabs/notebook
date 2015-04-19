# Generates random Location values
class LocationsGeneratorController < ApplicationController
  before_action :load_common_fields

  def name
    @root_name = add_fixes_to base_name

    render json: @root_name
  end

  private

  def base_name
    @syllables
      .sample(rand(@syllables_lower_limit...@syllables_upper_limit))
      .join
  end

  def add_fixes_to(base)
    if rand <= @prefix_occurrence
      return @prefixes.sample + ' ' + base
    elsif rand <= @postfix_occurrence
      return base + ' ' + @postfixes.sample
    else
      return base
    end
  end

  def load_common_fields
    @prefix_occurrence = 0.15
    @postfix_occurrence = 0.15
    @syllables_upper_limit = 4
    @syllables_lower_limit = 2
    @prefixes = t(:location_name_prefixes)
    @postfixes = t(:location_name_suffixes)
    @syllables = t(:location_name_syllables)
  end
end
