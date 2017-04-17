# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook, :for_writers, :for_roleplayers, :for_designers, :for_friends]

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

    ask_question
  end

  def prompts
    return redirect_to new_user_session_path unless user_signed_in?

    ask_question
  end

  def recent_content
    recent_content = current_user.content.values.flatten.compact

    @recent_edits   = recent_content.sort_by(&:updated_at).last(100).reverse
    @recent_creates = recent_content.sort_by(&:created_at).last(100).reverse
  end

  def for_writers
  end

  def for_roleplayers
  end

  def for_designers
  end

  def for_friends
    @subscriber_count = User.where(selected_billing_plan_id: [3, 4]).count
    @drawing_date = 'May 31, 2017'.to_date

    @subscriber_count = 20 # manual override to match graphics
  end

  def feature_voting
  end

  private

  class RetryMe < StandardError; end
  def ask_question
    # Try up to 10 times to actually fetch a question
    attempts = 0

    begin
      if @universe_scope.present? && attempts < 2
        content_pool = current_user.content_in_universe(@universe_scope).values.flatten
      else
        content_pool = current_user.content.values.flatten
      end

      @content = content_pool.sample
      @question = @content.question unless @content.nil?
      raise RetryMe if @content.present? && (@question.nil? || @question[:question].nil?) # :(
    rescue RetryMe
      attempts += 1
      retry if attempts < 10
    end
  end
end
