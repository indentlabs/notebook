# Controller for top-level pages of the site that do not have
# an associated model
class MainController < ApplicationController
  def index
    redirect_to :dashboard if user_signed_in?
  end

  def comingsoon
  end

  def anoninfo
  end

  def attribution
  end

  def dashboard
    content_type = %w(characters locations items).sample
    @content = current_user.send(content_type).sample
    # # TODO: get content_param_list from class controller to show question
    begin
      @question = QuestionService.question(Content.new @content.slice(*@content.attributes.keys))
    rescue
    end
  end
end
