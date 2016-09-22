# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  layout "landing", only: [:index, :about_notebook]

  def index
    redirect_to :dashboard if user_signed_in?
  end

  def about_notebook
  end

  def comingsoon
  end

  def anoninfo
  end

  def attribution
  end

  def dashboard
    return redirect_to new_user_session_path unless user_signed_in?

    content_type = %w(characters locations items).sample
    @content = current_user.send(content_type).sample

    begin
      questionable_params = @content.class.attribute_categories.flat_map { |_k, v| v[:attributes] }.reject { |k| k.end_with?('_id') }
      @question = QuestionService.question(Content.new @content.slice(*questionable_params))
    rescue
    end
  end
end
