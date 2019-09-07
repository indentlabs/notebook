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

  def prompts
    @sidenav_expansion = 'writing'
    @navbar_color = '#FF9800'

    set_random_content # for question
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

  # deprecated path todo cleanup
  def for_friends
    @subscriber_count = User.where(selected_billing_plan_id: [3, 4]).count
    @drawing_date = 'June 15, 2017 12:00pm'.to_date

    @subscriber_count = 20 # manual override to match graphics

    # todo it'd be nice to override the default devise authenticate_user! to set this for all pages
    session["user_return_to"] = request.original_url unless user_signed_in?
  end
  helper_method :resource_name, :resource, :devise_mapping

  def feature_voting
  end

  def privacyinfo
    @sidenav_expansion = 'help'
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
          @content = content_type.constantize.where(user: current_user, universe: @universe_scope).includes(:user)
        else
          @content = content_type.constantize.where(user: current_user).includes(:user)
        end
      end

      unless @content.klass.name == Universe.name
        @content = @content.includes(:universe)
      end

      @content = @content.sample
      return if @content.present?
    end
  end

  # todo these are helpers on a page we don't use anymore, so as soon as we remove for_friends we can get rid of these also
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
