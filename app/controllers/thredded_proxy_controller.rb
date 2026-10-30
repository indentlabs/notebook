class ThreddedProxyController < ApplicationController
  before_action :authenticate_user!, only: [:view_as_plaintext, :view_as_irc_log, :save_to_document]
  before_action :set_readable_topic, only: [:view_as_plaintext, :view_as_irc_log, :save_to_document]

  def topic
    topic = Thredded::Topic.find_by(slug: params[:slug])
    if topic.present?
      redirect_to thredded.messageboard_topic_path(
        messageboard_id: topic.messageboard_id,
        id:              topic.id
      )
    else
      redirect_back(fallback_location: root_path, notice: "The link you tried to visit is invalid or no longer exists.")
    end
  end

  def view_as_plaintext
    render plain: ForumsProsifyService.prosify_text(@topic, current_user)
  end

  def view_as_irc_log
    render plain: ForumsProsifyService.prosify_irc_log(@topic, current_user)
  end

  def save_to_document
    document = ForumsProsifyService.save_to_document(current_user, @topic)
    redirect_to document, notice: "Thread saved to document!"
  end

  private

  def set_readable_topic
    @topic = Thredded::Topic.find_by(slug: params[:slug])
    return if @topic && Thredded::TopicPolicy.new(current_user, @topic).read?

    redirect_back(fallback_location: root_path, notice: "The link you tried to visit is invalid or no longer exists.")
  end
end
