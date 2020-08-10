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
    @posts          = Thredded::Post.where(user_id: current_user.id)
    @private_topics = Thredded::PrivateTopic.where(user_id: current_user.id)
    @private_posts  = Thredded::PrivatePost.where(user_id: current_user.id)

    @threads_posted_to = Thredded::Topic.where(id: @posts.pluck(:postable_id) - @topics.pluck(:id))

    @followed_topics = current_user.thredded_topic_follows.includes(:topic)
  end

  def collaboration
    universe_ids             = current_user.universes.pluck(:id)
    @collaborators           = Contributor.where(universe_id: universe_ids).includes(:user, :universe)#.uniq { |c| c.user_id }
    @shared_universes        = current_user.universes.where(id: @collaborators.pluck(:universe_id))
    collaborating_ids        = Contributor.where(user_id: current_user.id).pluck(:universe_id)
    @collaborating_universes = Universe.where(id: collaborating_ids)
  end

  private

  def set_sidenav_expansion
    @sidenav_expansion = 'my account'
  end
end
