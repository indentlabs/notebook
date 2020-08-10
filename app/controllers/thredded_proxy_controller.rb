class ThreddedProxyController < ApplicationController
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
end
