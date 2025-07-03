class TemplateInitializationService
  def initialize(user, content_type)
    @user = user
    @content_type = content_type.downcase
    @content_type_class = @content_type.titleize.constantize
  end

  def initialize_default_template!
    # Load the YAML template structure
    yaml_path = Rails.root.join('config', 'attributes', "#{@content_type}.yml")
    unless File.exist?(yaml_path)
      Rails.logger.warn "No default template found for #{@content_type} at #{yaml_path}"
      return []
    end

    template_structure = YAML.load_file(yaml_path) || {}
    created_categories = []

    ActiveRecord::Base.transaction do
      # Create categories in YAML order, acts_as_list will handle positioning
      template_structure.each do |category_name, details|
        # Create category (ignoring soft-deleted ones)
        category = create_category(category_name, details)
        created_categories << category

        # Create fields for this category in YAML order
        if details[:attributes].present?
          details[:attributes].each do |field_details|
            create_field(category, field_details)
          end
        end
      end
    end

    # Clear any cached template data
    Rails.cache.delete("#{@content_type}_template_#{@user.id}")
    
    # Force correct ordering based on YAML file structure
    if created_categories.any?
      created_categories.first.backfill_categories_ordering!
    end
    
    created_categories
  end

  def recreate_template_after_reset!
    # This method is specifically for template resets
    # It assumes existing data has been cleaned up and we need fresh defaults
    
    Rails.logger.info "Recreating default template for user #{@user.id}, content_type #{@content_type}"
    result = initialize_default_template!
    
    # Force reload of the content type's cached categories
    if @content_type_class.respond_to?(:clear_attribute_cache)
      @content_type_class.clear_attribute_cache(@user)
    end
    
    result
  end

  def template_exists?
    # Check if user has any non-deleted template structure for this content type
    @user.attribute_categories
      .where(entity_type: @content_type)
      .exists?
  end

  def default_template_structure
    # Load and return the YAML structure without creating database records
    yaml_path = Rails.root.join('config', 'attributes', "#{@content_type}.yml")
    return {} unless File.exist?(yaml_path)
    
    YAML.load_file(yaml_path) || {}
  rescue => e
    Rails.logger.error "Error loading default template structure: #{e.message}"
    {}
  end

  private

  def create_category(category_name, details)
    # Only look for non-deleted categories
    category = @user.attribute_categories
      .where(entity_type: @content_type, name: category_name.to_s)
      .first

    if category.nil?
      # Let acts_as_list handle the positioning by creating at the end
      category = @user.attribute_categories.create!(
        entity_type: @content_type,
        name: category_name.to_s,
        label: details[:label] || category_name.to_s.titleize,
        icon: details[:icon] || 'help'
      )
      Rails.logger.debug "Created category: #{category.label} for #{@content_type} at position #{category.position}"
    else
      # Update existing category with current defaults (in case YAML changed)
      category.update!(
        label: details[:label] || category_name.to_s.titleize,
        icon: details[:icon] || 'help'
      )
      Rails.logger.debug "Updated existing category: #{category.label} for #{@content_type}"
    end

    category
  end

  def create_field(category, field_details)
    field_name = field_details[:name]
    field_type = field_details[:field_type].presence || "text_area"
    field_label = field_details[:label].presence || field_name.to_s.titleize
    
    # Determine field_options for link fields
    field_options = {}
    if field_type == 'link'
      linkable_types = determine_linkable_types_for_field(field_name)
      field_options = { linkable_types: linkable_types } if linkable_types.any?
      Rails.logger.debug "Setting linkable_types for #{field_label}: #{linkable_types.inspect}"
    end
    
    # Only look for non-deleted fields
    field = category.attribute_fields
      .where(old_column_source: field_name)
      .first

    if field.nil?
      # Let acts_as_list handle positioning for fields too
      field = category.attribute_fields.create!(
        old_column_source: field_name,
        user: @user,
        field_type: field_type,
        label: field_label,
        field_options: field_options,
        migrated_from_legacy: true
      )
      Rails.logger.debug "Created field: #{field.label} in category #{category.label}"
    else
      # Update existing field with current defaults
      field.update!(
        field_type: field_type,
        label: field_label,
        field_options: field_options,
        migrated_from_legacy: true
      )
      Rails.logger.debug "Updated existing field: #{field.label} in category #{category.label}"
    end

    field
  end

  private

  def determine_linkable_types_for_field(field_name)
    # Get the content class we're working with
    content_class = @content_type.classify.constantize
    
    # Check if this field has a relationship defined
    content_relations = Rails.application.config.content_relations || {}
    content_type_key = @content_type.to_sym
    
    if content_relations[content_type_key] && content_relations[content_type_key][field_name.to_sym]
      relation_info = content_relations[content_type_key][field_name.to_sym]
      
      # Get the relationship model class
      relationship_class_name = relation_info[:relationship_class]
      if relationship_class_name
        begin
          relationship_class = relationship_class_name.constantize
          
          # Find the belongs_to association that isn't the source
          source_association_name = relation_info[:source_key]&.to_s&.singularize
          
          relationship_class.reflect_on_all_associations(:belongs_to).each do |assoc|
            # Skip the association back to the source model
            next if assoc.name.to_s == source_association_name
            
            # This should be the target association
            target_class = assoc.klass
            return [target_class.name] if target_class
          end
        rescue => e
          Rails.logger.warn "Error determining linkable types for #{field_name}: #{e.message}"
        end
      end
    end
    
    # Fallback: try to infer from common field naming patterns
    case field_name.to_s
    when /owner|character|person|friend|sibling|parent|child|relative/
      ['Character']
    when /location|place|town|city|building/
      ['Location']
    when /item|object|thing|equipment|weapon|tool/
      ['Item']
    when /universe|world|setting/
      ['Universe']
    else
      # Default to allowing links to all major content types
      ['Character', 'Location', 'Item']
    end
  end
end