# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook]

  class RetryMe < StandardError; end

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

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
