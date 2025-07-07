class HelpController < ApplicationController
  # Make page_templates and organizing_with_universes public for sharing with non-users
  before_action :authenticate_user!, except: [:page_templates, :organizing_with_universes]

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
  
  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
