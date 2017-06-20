class SearchController < ApplicationController
  before_action :authenticate_user!

  def results
    @query = params[:q]

    @results = Hash.new([])
    current_user.content.each do |content_type, content_list|
      @results[content_type] = content_list.select { |content| search_match?(content, @query) }
    end
  end

  private

  # Returns whether a given piece of content matches against a given search query.
  # Usage: search_match?(some_character_instance, 'Bob') => true|false
  def search_match? content, query
    # We match if the query exists in any searchable fields on this content
    searchable_attributes_for(content.class).any? do |attribute|
      content_value = content.send(attribute)
      content_value.present? && content_value.to_s.downcase.include?(query.downcase)
    end
  end

  # Returns all attributes on a class that we match against in a search.
  # Usage: searchable_attributes_for(Character) => [:name, :role, ...]
  def searchable_attributes_for klass
    related_controller = "#{klass.to_s.pluralize}Controller".constantize.new
    related_controller.send(:content_param_list).select do |attribute|
      !attribute.is_a?(Hash) && searchable_attribute?(attribute.to_s)
    end
  end

  # Returns whether or not a particular attribute should be included on searches.
  # Usage: searchable_attribute?('name') => true|false
  def searchable_attribute? attribute
    !attribute.end_with?('_id') && !attribute.end_with?('_attributes') && !attribute.end_with?('_values')
  end
end
