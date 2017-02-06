# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout 'landing', only: [:index, :about_notebook]

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

    @content = current_user.content.values.flatten.sample
    @question = @content.question unless @content.nil?
  end
end
