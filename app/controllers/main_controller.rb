# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook, :for_writers, :for_roleplayers, :for_designers, :for_friends]

  before_action :authenticate_user!, only: [:dashboard, :prompts, :notes, :recent_content]
  before_action :cache_linkable_content_for_each_content_type, only: [:dashboard, :prompts]

  before_action do
    if !user_signed_in? && params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def index
    redirect_to(:dashboard) if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    @page_title = "My notebook"

    set_questionable_content # for questions
  end

  def infostack
  end

  def sascon
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

  def for_designers
    @page_title = "Designing games and everything within them"
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
end
