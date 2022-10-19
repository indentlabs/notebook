# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'tailwind/landing', only: [
      :index, :about_notebook, :for_writers, :for_roleplayers, :for_friends
  ]
  layout 'tailwind', only: [:prompts, :dashboard, :table_of_contents]

  before_action :authenticate_user!, only: [:dashboard, :prompts, :notes, :recent_content]
  before_action :cache_linkable_content_for_each_content_type, only: [:dashboard, :prompts]
  before_action :set_page_meta_tags

  before_action do
    if !user_signed_in? && params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def index
    redirect_to(:dashboard) if user_signed_in?

    @resource ||= User.new
    @resource_name = :user
    @devise_mapping ||= Devise.mappings[:user]
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    @page_title = "My notebook"

    set_questionable_content # for questions
  end

  def table_of_contents
    @toc_scope = @universe_scope || current_user
    @toc_user  = @universe_scope.try(:user) || current_user

    content_list = @toc_scope.content_list.sort_by { |page| page['name'] }

    @starred_pages = content_list.select { |page| page['favorite'] == 1 }
    @other_pages   = content_list.select { |page| page['favorite'] == 0 }

    @page_type_counts = Hash.new(0)
    content_list.each { |page| @page_type_counts[page['page_type']] += 1 }
  end

  def infostack
  end

  def sascon
  end

  def paper
    @navbar_color = '#4CAF50'

    @total_notebook_pages   = 0
    @total_pages_equivalent = 0
    @total_trees_saved      = 0

    @per_page_savings = {}

    (Rails.application.config.content_types[:all] + [Timeline, Document]).each do |content_type|
      physical_page_equivalent = GreenService.total_physical_pages_equivalent(content_type)
      tree_equivalent          = physical_page_equivalent.to_f / GreenService::SHEETS_OF_PAPER_PER_TREE

      @per_page_savings[content_type.name] = {
        digital: content_type.last.try(:id) || 0,
        pages:   physical_page_equivalent,
        trees:   tree_equivalent
      }

      @total_notebook_pages   += @per_page_savings.dig(content_type.name, :digital)
      @total_pages_equivalent += @per_page_savings.dig(content_type.name, :pages)
      @total_trees_saved      += @per_page_savings.dig(content_type.name, :trees)
    end
  end

  def prompts
    @sidenav_expansion = 'writing'
    @navbar_color = '#FF9800'
    @page_title = "Writing prompts"

    set_questionable_content # for question
  end

  # deprecated path just kept around for bookmarks for a while
  def notes
    redirect_to edit_document_path(current_user.documents.first)
  end

  def recent_content
  end

  def for_writers
    @page_title = "Creating fictional worlds and everything within them"
  end

  def for_roleplayers
    @page_title = "Building campaigns and everything within them"
  end

  def feature_voting
  end

  def privacyinfo
    @sidenav_expansion = 'my account'
  end

  private

  def set_questionable_content
    @content = @current_user_content.except(*%w(Timeline Document)).values.flatten.sample
    @attribute_field_to_question = SerendipitousService.question_for(@content)
  end

  def set_page_meta_tags
    set_meta_tags(
      site: "The smart notebook for worldbuilders - Notebook.ai",
      page: ''
    )
  end
end
