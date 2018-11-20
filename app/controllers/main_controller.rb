# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook, :for_writers, :for_roleplayers, :for_designers, :for_friends]

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
    return redirect_to new_user_session_path unless user_signed_in?

    set_random_content # for questions
  end

  def prompts
    return redirect_to(new_user_session_path) unless user_signed_in?

    set_random_content # for question
  end

  def notes
    return redirect_to(new_user_session_path) unless user_signed_in?
    redirect_to edit_document_path(current_user.documents.first)
  end

  def recent_content
    # todo optimize this / use Attributes
    return [] if @activated_content_types.nil?

    @recent_edits = @activated_content_types.flat_map { |klass|
      klass.constantize
           .where(user_id: current_user.id)
           .order(updated_at: :desc)
           .limit(100)
    }.sort_by(&:updated_at)
    .last(100)
    .reverse

    @recent_creates = @activated_content_types.flat_map { |klass|
      klass.constantize
           .where(user_id: current_user.id)
           .order(created_at: :desc)
           .limit(100)
    }.sort_by(&:created_at)
    .last(100)
    .reverse
  end

  def for_writers
  end

  def for_roleplayers
  end

  def for_designers
  end

  def for_friends
    @subscriber_count = User.where(selected_billing_plan_id: [3, 4]).count
    @drawing_date = 'June 15, 2017 12:00pm'.to_date

    @subscriber_count = 20 # manual override to match graphics

    session["user_return_to"] = request.original_url unless user_signed_in?
  end
  helper_method :resource_name, :resource, :devise_mapping

  def feature_voting
  end

  private

  def set_random_content
    @activated_content_types.shuffle.each do |content_type|
      if content_type.downcase == "universe"
        if @universe_scope.present?
          # when we want to enable prompts for contributing universes we can remove the user:
          # selector here, but we will need to verify the user has permission to see the universe
          # when we do that, or else prompts could open leak
          @content = content_type.constantize.where(user: current_user, id: @universe_scope.id).sample
        else
          @content = content_type.constantize.where(user: current_user).sample
        end
      else
        if @universe_scope.present?
          @content = content_type.constantize.where(user: current_user, universe: @universe_scope).sample
        else
          @content = content_type.constantize.where(user: current_user).sample
        end
      end

      return if @content.present?
    end
  end

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
