class StreamController < ApplicationController
  before_action :set_stream_navbar_actions, only: [:index, :global]
  before_action :set_stream_navbar_color, only: [:index, :global]
  before_action :set_sidenav_expansion

  def index
    followed_users = current_user.followed_users.pluck(:id)
    @feed = ContentPageShare.where(user_id: followed_users + [current_user.id])
      .order('created_at DESC')
      .includes([:content_page, :user, :share_comments])
      .limit(100)
  end

  def community
  end

  def global
    @feed = ContentPageShare.all
      .order('created_at DESC')
      .includes([:content_page, :user, :share_comments])
      .limit(100)
  end

  def set_stream_navbar_color
    @navbar_color = '#CE93D8'
  end

  # For showing a specific piece of content
  def set_stream_navbar_actions
    @navbar_actions = [
      {
        label: 'From Your Network',
        href: main_app.stream_path
      },
      {
        label: 'Around the world',
        href: main_app.stream_world_path
      }
    ]
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'community'
  end
end
