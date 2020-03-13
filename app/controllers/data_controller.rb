class DataController < ApplicationController
  before_action :authenticate_user!

  before_action :set_sidenav_expansion

  def index
  end

  def archive
  end

  def uploads
  end

  def usage
    @content = current_user.content
  end

  def discussions
    @topics         = Thredded::Topic.where(user_id: current_user.id)
    @posts          = Thredded::Post.where(user_id: current_user.id)
    @private_topics = Thredded::PrivateTopic.where(user_id: current_user.id)
    @private_posts  = Thredded::PrivatePost.where(user_id: current_user.id)
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
