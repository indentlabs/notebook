class TemplateExportService
  def initialize(user, content_type)
    @user = user
    @content_type = content_type.downcase
    @content_type_class = @content_type.titleize.constantize
    @categories = load_template_structure
  end

  def export_as_yaml
    template_data = build_template_data
    
    # Generate YAML with comments and metadata
    yaml_content = []
    yaml_content << "# #{@content_type.titleize} Template Export"
    yaml_content << "# Generated: #{Time.current.strftime('%Y-%m-%d %H:%M:%S UTC')}"
    yaml_content << "# Content Type: #{@content_type.titleize}"
    yaml_content << "# Categories: #{template_data[:statistics][:total_categories]} | Fields: #{template_data[:statistics][:total_fields]} | User: #{@user.username || @user.email}"
    yaml_content << ""
    yaml_content << template_data.to_yaml
    
    yaml_content.join("\n")
  end

  def export_as_markdown
    template_data = build_template_data
    
    markdown_content = []
    markdown_content << "# #{@content_type.titleize} Template"
    markdown_content << ""
    markdown_content << "**Generated:** #{Time.current.strftime('%B %d, %Y at %H:%M UTC')}"
    markdown_content << "**Content Type:** #{@content_type.titleize}"
    markdown_content << "**Categories:** #{template_data[:statistics][:total_categories]} | **Fields:** #{template_data[:statistics][:total_fields]}"
    markdown_content << ""
    
    # Template overview
    markdown_content << "## Template Overview"
    markdown_content << ""
    markdown_content << "This template defines the structure and fields for your #{@content_type.titleize.downcase} pages."
    markdown_content << ""
    
    # Statistics
    stats = template_data[:statistics]
    markdown_content << "### Statistics"
    markdown_content << ""
    markdown_content << "- **Total Categories:** #{stats[:total_categories]}"
    markdown_content << "- **Total Fields:** #{stats[:total_fields]}"
    markdown_content << "- **Hidden Categories:** #{stats[:hidden_categories]}"
    markdown_content << "- **Hidden Fields:** #{stats[:hidden_fields]}"
    markdown_content << "- **Custom Categories:** #{stats[:custom_categories]}"
    markdown_content << ""
    
    # Categories and fields
    markdown_content << "## Template Structure"
    markdown_content << ""
    
    template_data[:template][:categories].each do |category_name, category_data|
      icon_display = category_data[:icon] ? " 📋" : ""
      hidden_display = category_data[:hidden] ? " (Hidden)" : ""
      
      markdown_content << "### #{category_data[:label]}#{icon_display}#{hidden_display}"
      markdown_content << ""
      
      if category_data[:description].present?
        markdown_content << "_#{category_data[:description]}_"
        markdown_content << ""
      end
      
      if category_data[:fields].any?
        category_data[:fields].each do |field_name, field_data|
          field_icon = case field_data[:field_type]
                      when 'name' then '📝'
                      when 'text_area' then '📄'
                      when 'link' then '🔗'
                      when 'universe' then '🌍'
                      when 'tags' then '🏷️'
                      else '📋'
                      end
          
          hidden_text = field_data[:hidden] ? " _(Hidden)_" : ""
          markdown_content << "- **#{field_data[:label]}** #{field_icon}#{hidden_text}"
          
          if field_data[:description].present?
            markdown_content << "  - _#{field_data[:description]}_"
          end
          
          if field_data[:field_type] == 'link' && field_data[:field_options][:linkable_types].present?
            linkable_types = field_data[:field_options][:linkable_types].join(', ')
            markdown_content << "  - Links to: #{linkable_types}"
          end
        end
        markdown_content << ""
      else
        markdown_content << "_No fields in this category_"
        markdown_content << ""
      end
    end
    
    # Customizations
    if template_data[:customizations].any?
      markdown_content << "## Template Customizations"
      markdown_content << ""
      markdown_content << "The following customizations have been made from the default template:"
      markdown_content << ""
      
      template_data[:customizations].each do |customization|
        case customization[:action]
        when 'added_category'
          markdown_content << "- ➕ **Added Category:** #{customization[:label]}"
        when 'modified_field'
          markdown_content << "- ✏️ **Modified Field:** #{customization[:category]} → #{customization[:field]} (#{customization[:change]})"
        when 'hidden_category'
          markdown_content << "- 👁️ **Hidden Category:** #{customization[:label]}"
        when 'hidden_field'
          markdown_content << "- 👁️ **Hidden Field:** #{customization[:category]} → #{customization[:field]}"
        end
      end
      markdown_content << ""
    end
    
    markdown_content << "---"
    markdown_content << "_Template exported from Notebook.ai on #{Time.current.strftime('%B %d, %Y')}_"
    
    markdown_content.join("\n")
  end

  private

  def load_template_structure
    @content_type_class
      .attribute_categories(@user, show_hidden: true)
      .shown_on_template_editor
      .includes(:attribute_fields)
      .order(:position)
  end

  def build_template_data
    template_categories = {}
    total_fields = 0
    hidden_categories = 0  
    hidden_fields = 0
    custom_categories = 0
    customizations = []
    
    # Load default template structure for comparison
    default_structure = load_default_template_structure
    
    @categories.each do |category|
      total_fields += category.attribute_fields.count
      hidden_categories += 1 if category.hidden?
      
      # Check if this is a custom category (not in defaults)
      unless default_structure.key?(category.name.to_sym)
        custom_categories += 1
        customizations << {
          action: 'added_category',
          name: category.name,
          label: category.label
        }
      end
      
      # Track hidden categories
      if category.hidden?
        customizations << {
          action: 'hidden_category',
          name: category.name,
          label: category.label
        }
      end
      
      # Build category data
      category_fields = {}
      category.attribute_fields.order(:position).each do |field|
        hidden_fields += 1 if field.hidden?
        
        # Track hidden fields
        if field.hidden?
          customizations << {
            action: 'hidden_field',
            category: category.label,
            field: field.label
          }
        end
        
        category_fields[field.name.to_sym] = {
          label: field.label,
          field_type: field.field_type,
          position: field.position,
          description: field.description,
          hidden: field.hidden?,
          field_options: field.field_options || {}
        }
      end
      
      template_categories[category.name.to_sym] = {
        label: category.label,
        icon: category.icon,
        description: category.description,
        position: category.position,
        hidden: category.hidden?,
        fields: category_fields
      }
    end
    
    {
      template: {
        content_type: @content_type,
        icon: @content_type_class.icon,
        categories: template_categories
      },
      statistics: {
        total_categories: @categories.count,
        total_fields: total_fields,
        hidden_categories: hidden_categories,
        hidden_fields: hidden_fields,
        custom_categories: custom_categories
      },
      customizations: customizations
    }
  end
  
  def load_default_template_structure
    # Load the default YAML structure for comparison
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