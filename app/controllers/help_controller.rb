class HelpController < ApplicationController
  # Make all help pages public for SEO and accessibility
  # before_action :authenticate_user!

  before_action :set_sidenav_expansion

  layout 'tailwind'

  def index
    @page_title = "Help center"
  end

  def page_templates
    @page_title = "Page Templates"
    @meta_description = "Learn how to customize page templates in Notebook.ai to structure your creative content perfectly. Complete guide to categories, fields, and template management."
  end

  def organizing_with_universes
    @page_title = "Organizing with Universes"
    @meta_description = "Master the art of worldbuilding organization with universes in Notebook.ai. Learn about privacy, collaboration, focus mode, and best practices for managing complex fictional worlds."
  end

  def premium_features
    @page_title = "Premium Features Guide"
    @meta_description = "Comprehensive guide to Notebook.ai Premium features including advanced content types, document analysis, unlimited storage, timelines, collections, and collaboration tools."
  end

  def free_features
    @page_title = "Free Features Guide"
    @meta_description = "Complete overview of free features in Notebook.ai including core worldbuilding pages, document creation, universe organization, community features, and collaboration tools."
  end

  def your_first_universe
    @page_title = "Your First Universe - Getting Started Guide"
    @meta_description = "Step-by-step guide to creating your first fictional universe in Notebook.ai. Learn how to organize characters, locations, items, and build the foundation of your worldbuilding project."
  end

  def page_visualization
    @page_title = "Page Visualization with Basil"
    @meta_description = "Complete guide to visualizing your worldbuilding content with Basil. Learn how to generate character portraits, location art, and item illustrations from your page details."
  end

  def document_analysis
    @page_title = "Document Analysis Guide"
    @meta_description = "Master Notebook.ai's AI-powered document analysis feature. Learn how to automatically extract characters, locations, and plot elements from your manuscripts and stories."
  end

  def organizing_with_tags
    @page_title = "Organizing with Tags"
    @meta_description = "Master the art of content organization using tags in Notebook.ai. Learn how to create, manage, and use tags to efficiently organize and discover your worldbuilding content."
  end
  
  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
