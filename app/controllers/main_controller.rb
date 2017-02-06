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

    # Try up to 5 times to actually fetch a question
    attempts = 0

    begin
      @content = current_user.content.values.flatten.sample
      @question = @content.question unless @content.nil?

      raise RetryMe if @question.nil? || @question[:question].nil? # :(
    rescue RetryMe
      retry if attempts < 5
    end
  end
end
