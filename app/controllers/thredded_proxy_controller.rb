class ThreddedProxyController < ApplicationController
  before_action :authenticate_user!, only: [:view_as_plaintext, :view_as_irc_log, :save_to_document]

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
    topic = Thredded::Topic.find_by(slug: params[:slug])
    render plain: ForumsProsifyService.prosify_text(topic)
  end

  def view_as_irc_log
    topic = Thredded::Topic.find_by(slug: params[:slug])
    render plain: ForumsProsifyService.prosify_irc_log(topic)
  end

  def save_to_document
    topic = Thredded::Topic.find_by(slug: params[:slug])
    document = ForumsProsifyService.save_to_document(current_user, topic)
    redirect_to document, notice: "Thread saved to document!"
  end
end
