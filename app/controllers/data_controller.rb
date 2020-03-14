class DataController < ApplicationController
  before_action :authenticate_user!

  before_action :set_sidenav_expansion

  def index
  end

  def archive
  end

  def uploads
    @used_kb     = current_user.image_uploads.sum(:src_file_size) / 1000
    @remaining_kb = current_user.upload_bandwidth_kb.abs

    if current_user.upload_bandwidth_kb < 0
      @percent_used = 100
    else
      @percent_used = (@used_kb.to_f / (@used_kb + @remaining_kb) * 100).round(3)
    end
  end

  def usage
    @content = current_user.content
  end

  def discussions
    @topics         = Thredded::Topic.where(user_id: current_user.id)
    @posts          = Thredded::Post.where(user_id: current_user.id).includes(:postable)
    @private_topics = Thredded::PrivateTopic.where(user_id: current_user.id)
    @private_posts  = Thredded::PrivatePost.where(user_id: current_user.id)

    @threads_posted_to = Thredded::Topic.where(id: @posts.pluck(:postable_id) - @topics.pluck(:id))
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
