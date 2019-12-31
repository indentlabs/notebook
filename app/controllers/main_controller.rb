# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook, :for_writers, :for_roleplayers, :for_designers, :for_friends]

  before_action :authenticate_user!, only: [:dashboard, :prompts, :notes, :recent_content]

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
    set_random_content # for questions
  end

  def infostack
  end

  def prompts
    @sidenav_expansion = 'writing'
    @navbar_color = '#FF9800'

    set_random_content # for question
    @attribute_field_to_question = SerendipitousService.question_for(@content)
  end

  # deprecated path just kept around for bookmarks for a while
  def notes
    redirect_to edit_document_path(current_user.documents.first)
  end

  def recent_content
    # todo optimize this / use Attributes
    return [] if @activated_content_types.nil?

    @recent_edits = current_user.recent_content_list(limit: 50)
    @recent_creates = current_user.recent_content_list_by_create(limit: 50)
  end

  def for_writers
  end

  def for_roleplayers
  end

  def for_designers
  end

  def feature_voting
  end

  def privacyinfo
    @sidenav_expansion = 'my account'
  end

  private

  def set_random_content
    @activated_content_types.shuffle.each do |content_type|
      if content_type == Universe.name
        if @universe_scope.present?
          @content = content_type.constantize.where(user: current_user, id: @universe_scope.id).includes(:user)
        else
          @content = content_type.constantize.where(user: current_user).includes(:user)
        end
      else
        if @universe_scope.present?
          # when we want to enable prompts for contributing universes we can remove the user:
          # selector here, but we will need to verify the user has permission to see the universe
          # when we do that, or else prompts could open leak
          @content = content_type.constantize.where(user: current_user, universe: @universe_scope).includes(:user, :universe)
        else
          @content = content_type.constantize.where(user: current_user).includes(:user, :universe)
        end
      end

      @content = @content.sample
      return if @content.present?
    end
  end
end
