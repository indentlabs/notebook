# Controller for CRUD actions related to any content
class ContentController < ApplicationController
  before_action :authenticate_user!, except: [:show, :changelog]
  before_action :set_content_type, only: [:attributes, :attributes_tailwind, :export_template]
  before_action :set_attributes_content_type, only: [:attributes, :attributes_tailwind, :export_template]

  layout 'tailwind'
  
  def attributes
    @attribute_categories = @content_type_class
      .attribute_categories(current_user, show_hidden: true)
      .shown_on_template_editor
      .order(:position)

    @dummy_model = @content_type_class.new
  end
  
  def attributes_tailwind
    @attribute_categories = @content_type_class
      .attribute_categories(current_user, show_hidden: true)
      .shown_on_template_editor
      .order(:position)

    @dummy_model = @content_type_class.new
    
    # Use the Tailwind layout
    render :attributes_tailwind
  end
  
  def export_template
    service = TemplateExportService.new(current_user, @content_type)
    
    case params[:format]
    when 'yml', 'yaml'
      send_data service.export_as_yaml, 
                filename: "#{@content_type}_template.yml", 
                type: 'text/plain'
    when 'md', 'markdown'
      send_data service.export_as_markdown,
                filename: "#{@content_type}_template.md", 
                type: 'text/plain'
    else
      redirect_back fallback_location: root_path, alert: 'Invalid export format'
    end
  end
  

  private
  
  def set_content_type
    @content_type = params[:content_type]
  end

  def set_attributes_content_type
    # Find the content type from the parameter
    @content_type_class = @content_type.titleize.constantize
    
    unless Rails.application.config.content_type_names[:all].include?(@content_type_class.name)
      raise "Invalid content type: #{@content_type}"
    end
  end
  
  def toggle_image_pin
    # Method stub for route
  end
  
  def link_field_update
    # Method stub for route
  end
  
  def name_field_update
    # Method stub for route  
  end
  
  def text_field_update
    # Method stub for route
  end
  
  def tags_field_update
    # Method stub for route
  end
  
  def universe_field_update
    # Method stub for route
  end
end