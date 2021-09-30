class StreamController < ApplicationController
  before_action :authenticate_user!, except: [:global]
  before_action :set_stream_navbar_actions, only: [:index, :global]
  before_action :set_stream_navbar_color, only: [:index, :global]
  before_action :set_sidenav_expansion
  before_action :cache_linkable_content_for_each_content_type, only: [:index]

  def index
    @page_title = "What's happening"

    followed_users   = current_user.followed_users.pluck(:id)
    blocked_users    = current_user.blocked_users.pluck(:id)
    blocked_by_users = current_user.blocked_by_users.pluck(:id)

    @feed = ContentPageShare.where(user_id: followed_users + [current_user.id] - blocked_users - blocked_by_users)
      .order('created_at DESC')
      .includes([:content_page, :secondary_content_page])
      .includes({ share_comments: [:user], user: [:avatar_attachment] })
      .limit(25)
    
    @users_to_follow = User.where(
      # Users who have shared at least 1 page to their stream
      id: ContentPageShare.where(content_page_type: Rails.application.config.content_type_names[:all])
            .where.not(id: current_user.try(:id))
            .pluck(:user_id)
    ).order('selected_billing_plan_id DESC').limit(250).sample(12)
  end

  def community
  end

  def global
    @page_title = "What's happening around the world"

    if user_signed_in?
      blocked_users    = current_user.blocked_users.pluck(:id)
      blocked_by_users = current_user.blocked_by_users.pluck(:id)
    else
      blocked_users    = []
      blocked_by_users = []
    end

    @feed = ContentPageShare.all
      .where.not(user_id: blocked_users + blocked_by_users)
      .order('created_at DESC')
      .includes([:content_page, :secondary_content_page])
      .includes({ share_comments: [:user], user: [:avatar_attachment] })
      .limit(25)
  end

  def set_stream_navbar_color
    @navbar_color = '#CE93D8'
  end

  # For showing a specific piece of content
  def set_stream_navbar_actions
    @navbar_actions = [
      user_signed_in? ? {
        label: 'You & Your Network',
        href: main_app.stream_path
      } : nil,
      {
        label: 'Around the world',
        href: main_app.stream_world_path
      }
    ].compact
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'community'
  end
end
