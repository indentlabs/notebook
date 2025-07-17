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
  
  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
