class TemplateResetService
  require 'set'
  
  def initialize(user, content_type)
    @user = user
    @content_type = content_type.downcase
    @content_type_class = @content_type.titleize.constantize
  end

  def reset_template!
    reset_summary = analyze_reset_impact
    
    ActiveRecord::Base.transaction do
      # Soft delete all existing categories and fields for this content type
      existing_categories = @user.attribute_categories
        .where(entity_type: @content_type)
        .includes(:attribute_fields)
      
      # Store counts for summary
      reset_summary[:deleted_categories] = existing_categories.count
      reset_summary[:deleted_fields] = existing_categories.sum { |cat| cat.attribute_fields.count }
      
      # Soft delete all fields first (to maintain referential integrity)
      existing_categories.each do |category|
        category.attribute_fields.destroy_all
      end
      
      # Then soft delete all categories
      existing_categories.destroy_all
      
      # Now recreate the default template structure
      template_service = TemplateInitializationService.new(@user, @content_type)
      created_categories = template_service.recreate_template_after_reset!
      
      # Store creation counts for summary
      reset_summary[:created_categories] = created_categories.count
      reset_summary[:created_fields] = created_categories.sum { |cat| cat.attribute_fields.count }
      
      Rails.logger.info "Template reset completed for user #{@user.id}, content_type #{@content_type}. " \
                       "Deleted: #{reset_summary[:deleted_categories]} categories, #{reset_summary[:deleted_fields]} fields. " \
                       "Created: #{reset_summary[:created_categories]} categories, #{reset_summary[:created_fields]} fields."
    end
    
    reset_summary[:success] = true
    reset_summary[:message] = "Template has been reset to defaults successfully! " \
                             "Removed #{reset_summary[:deleted_categories]} custom categories and #{reset_summary[:deleted_fields]} custom fields. " \
                             "Recreated #{reset_summary[:created_categories]} default categories with #{reset_summary[:created_fields]} default fields."
    reset_summary
  rescue => e
    Rails.logger.error "Template reset failed for user #{@user.id}, content_type #{@content_type}: #{e.message}"
    reset_summary.merge({
      success: false,
      error: e.message,
      created_categories: 0,
      created_fields: 0
    })
  end

  def analyze_reset_impact
    # Get current template structure to show what will be reset
    current_categories = @user.attribute_categories
      .where(entity_type: @content_type)
      .includes(attribute_fields: :attribute_values)
      .order(:position)
    
    custom_categories = []
    modified_fields = []
    data_loss_warnings = []
    filled_attributes_count = 0
    affected_pages_count = 0
    affected_pages = Set.new
    
    # Load default template to compare against
    default_structure = load_default_template_structure
    
    current_categories.each do |category|
      category_info = {
        id: category.id,
        name: category.name,
        label: category.label,
        icon: category.icon,
        custom: !default_structure.key?(category.name.to_sym),
        hidden: category.hidden?,
        field_count: category.attribute_fields.count
      }
      
      # Check if category is custom (not in defaults)
      if !default_structure.key?(category.name.to_sym)
        custom_categories << category_info
      end
      
      # Check for modified fields and analyze attribute data
      category.attribute_fields.each do |field|
        # Count filled attribute values (non-empty, non-nil)
        filled_values = field.attribute_values.where(
          "value IS NOT NULL AND value != ''"
        )
        
        filled_count = filled_values.count
        if filled_count > 0
          # Track unique pages that have data in this field
          filled_values.each do |attr|
            affected_pages.add("#{attr.entity_type}:#{attr.entity_id}")
          end
          
          filled_attributes_count += filled_count
          
          data_loss_warnings << {
            category: category.label,
            field: field.label,
            value_count: filled_count,
            filled_count: filled_count # For backward compatibility
          }
        end
        
        # Check if field is custom or modified
        default_category = default_structure[category.name.to_sym]
        if default_category
          default_field = default_category[:attributes]&.find { |f| f[:name].to_s == field.name }
          if !default_field
            modified_fields << {
              category: category.label,
              field: field.label,
              type: 'custom_field'
            }
          end
        end
      end
    end
    
    affected_pages_count = affected_pages.size
    
    # Load the default template to show what will be recreated
    template_service = TemplateInitializationService.new(@user, @content_type)
    default_structure = template_service.default_template_structure
    
    default_categories_count = default_structure.count
    default_fields_count = default_structure.sum { |_, details| details[:attributes]&.count || 0 }
    
    {
      total_categories: current_categories.count,
      total_fields: current_categories.sum { |cat| cat.attribute_fields.count },
      custom_categories: custom_categories,
      modified_fields: modified_fields,
      data_loss_warnings: data_loss_warnings,
      filled_attributes_count: filled_attributes_count,
      affected_pages_count: affected_pages_count,
      will_restore_defaults: !default_structure.empty?,
      default_categories_count: default_categories_count,
      default_fields_count: default_fields_count,
      default_structure: default_structure
    }
  end

  private

  def load_default_template_structure
    # Load the default YAML structure
    yaml_path = Rails.root.join('config', 'attributes', "#{@content_type}.yml")
    if File.exist?(yaml_path)
      YAML.load_file(yaml_path) || {}
    else
      {}
    end
  rescue => e
    Rails.logger.warn "Could not load default template structure for #{@content_type}: #{e.message}"
    {}
  end
end