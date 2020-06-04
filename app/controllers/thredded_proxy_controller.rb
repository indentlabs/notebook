class ThreddedProxyController < ApplicationController
  def topic
    topic = Thredded::Topic.find_by(slug: params[:slug])
    redirect_to thredded.messageboard_topic_path(
      messageboard_id: topic.messageboard_id,
      id:              topic.id
    )
  end
end
