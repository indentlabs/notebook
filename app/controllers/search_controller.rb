class SearchController < ApplicationController
  before_action :authenticate_user!

  def results
    @query  = params[:q]&.strip
    @sort   = params[:sort] || 'relevance'
    @filter = params[:filter] || 'all'

    # Return early if query is empty or too short
    if @query.blank? || @query.length < 2
      @matched_attributes = Attribute.none
      @result_types = []
      @seen_result_pages = {}
      return
    end

    # Search both Attribute values AND entity names (for content still in old-style columns)
    
    # 1. Search Attribute values (new-style fields) with multi-word support
    @matched_attributes = Attribute
      .joins(:attribute_field)
      .where(user_id: current_user.id)
      .where.not(value: [nil, ''])
    
    # Build multi-word search conditions for attributes
    search_words = @query.split(/\s+/).reject(&:blank?)
    if search_words.length > 1
      # Multi-word search: all words must be present (AND logic)
      word_conditions = search_words.map { "LOWER(value) LIKE LOWER(?)" }.join(" AND ")
      word_values = search_words.map { |word| "%#{word}%" }
      @matched_attributes = @matched_attributes.where(word_conditions, *word_values)
    else
      # Single word search
      @matched_attributes = @matched_attributes.where("LOWER(value) LIKE LOWER(?)", "%#{@query}%")
    end

    # 2. Also search entity names (old-style name columns) with multi-word support
    @matched_names = []
    Rails.application.config.content_types[:all].each do |content_type|
      begin
        model_class = content_type.name.constantize
        if model_class.column_names.include?('name')
          # Build multi-word search for entity names
          if search_words.length > 1
            # Multi-word search: all words must be present in name
            name_conditions = search_words.map { "LOWER(name) LIKE LOWER(?)" }.join(" AND ")
            name_values = search_words.map { |word| "%#{word}%" }
            matching_entities = model_class
              .where(user_id: current_user.id)
              .where(name_conditions, *name_values)
          else
            # Single word search
            matching_entities = model_class
              .where(user_id: current_user.id)
              .where("LOWER(name) LIKE LOWER(?)", "%#{@query}%")
          end
          
          matching_entities.each do |entity|
            # Create a virtual attribute-like object for the name match
            @matched_names << OpenStruct.new(
              id: "name_#{entity.class.name}_#{entity.id}",
              entity_type: entity.class.name,
              entity_id: entity.id,
              value: entity.name,
              attribute_field: OpenStruct.new(label: 'Name', field_type: 'name'),
              created_at: entity.created_at,
              updated_at: entity.updated_at
            )
          end
        end
      rescue => e
        # Skip any content types that don't exist or have issues
        Rails.logger.debug "Skipping search in #{content_type.name}: #{e.message}"
      end
    end

    # Get result types for filtering (before pagination)
    @result_types = (@matched_attributes.pluck(:entity_type) + @matched_names.map(&:entity_type)).uniq

    # Apply content type filter to both attribute results and name results
    if @filter != 'all'
      @matched_attributes = @matched_attributes.where(entity_type: @filter)
      @matched_names.select! { |name_match| name_match.entity_type == @filter }
    end

    # Combine both result sets for sorting and pagination
    all_matches = @matched_attributes.to_a + @matched_names

    # Apply search refinement if provided
    if params[:refine].present?
      refine_query = params[:refine].strip
      all_matches.select! do |match|
        match.value.downcase.include?(refine_query.downcase)
      end
    end

    # Apply sorting to combined results
    case @sort
    when 'relevance'
      # Order by relevance: exact matches first, then by entity type and id
      all_matches.sort_by! do |match|
        exact_match = match.value.downcase == @query.downcase ? 0 : 1
        [exact_match, match.entity_type, match.entity_id]
      end
    when 'recent'
      all_matches.sort_by! { |match| -match.created_at.to_i }
    when 'oldest'
      all_matches.sort_by! { |match| match.created_at.to_i }
    end

    # Add pagination to prevent performance issues with large result sets
    page = [params[:page]&.to_i || 1, 1].max  # Ensure page is at least 1
    per_page = 100
    start_index = (page - 1) * per_page
    @matched_attributes = all_matches[start_index, per_page] || []

    # Debug: Log search info in development
    if Rails.env.development?
      Rails.logger.info "=== Search Debug ==="
      Rails.logger.info "Query: '#{@query}'"
      Rails.logger.info "Attribute matches: #{@matched_attributes.respond_to?(:count) ? @matched_attributes.count : @matched_attributes.size}"
      Rails.logger.info "Name matches: #{@matched_names.size}"
      Rails.logger.info "Total results: #{all_matches.size}"
      Rails.logger.info "Sample results: #{@matched_attributes.first(3).map { |m| "#{m.attribute_field.label}: '#{m.value}' (#{m.entity_type}##{m.entity_id})" }}"
    end

    @seen_result_pages = {}
  end

  def autocomplete
    @query = params[:q]&.strip
    
    # Return empty results for short or empty queries
    if @query.blank? || @query.length < 2
      render json: []
      return
    end

    results = []
    
    # Fast name-only search across all content types
    Rails.application.config.content_types[:all].each do |content_type|
      begin
        model_class = content_type.name.constantize
        
        # Only search content types that have name columns
        if model_class.column_names.include?('name')
          # Fast query with limit to prevent slow searches
          matching_entities = model_class
            .where(user_id: current_user.id)
            .where("LOWER(name) LIKE LOWER(?)", "%#{@query}%")
            .limit(5) # Limit per content type
            .select(:id, :name, :created_at) # Only select needed columns
          
          matching_entities.each do |entity|
            results << {
              id: entity.id,
              name: entity.name,
              type: content_type.name,
              icon: content_type.icon,
              color: content_type.hex_color,
              url: main_app.polymorphic_path(entity),
              created_at: entity.created_at
            }
          end
        end
      rescue => e
        # Skip any content types that have issues
        Rails.logger.debug "Autocomplete: Skipping #{content_type.name}: #{e.message}"
      end
      
      # Stop if we have enough results
      break if results.size >= 15
    end
    
    # Sort by relevance: exact matches first, then by name
    results.sort_by! do |result|
      exact_match = result[:name].downcase == @query.downcase ? 0 : 1
      [exact_match, result[:name].downcase]
    end
    
    # Limit total results
    results = results.first(12)
    
    render json: results
  end

  helper_method :highlight_search_terms

  private

  def highlight_search_terms(text, query)
    return text if query.blank?
    
    words = query.split(/\s+/).reject(&:blank?)
    highlighted = text
    
    words.each do |word|
      highlighted = highlighted.gsub(
        /\b#{Regexp.escape(word)}\b/i,
        '<mark class="bg-yellow-200 px-1 py-0.5 rounded text-black font-medium">\0</mark>'
      )
    end
    
    highlighted.html_safe
  end

  def search_params
    params.permit(:q, :sort, :filter, :page, :refine)
  end
end
