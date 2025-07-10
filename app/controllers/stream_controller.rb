class StreamController < ApplicationController
  layout 'tailwind', only: [:index, :global]

  before_action :authenticate_user!
  before_action :set_stream_navbar_actions, only: [:index, :global]
  before_action :set_stream_navbar_color, only: [:index, :global]
  before_action :set_sidenav_expansion
  before_action :cache_linkable_content_for_each_content_type, only: [:index, :global]

  def index
    @page_title = "What's happening"

    followed_users   = current_user.followed_users.pluck(:id)
    blocked_users    = current_user.blocked_users.pluck(:id)
    blocked_by_users = current_user.blocked_by_users.pluck(:id)

    @feed = ContentPageShare.where(user_id: followed_users + [current_user.id] - blocked_users - blocked_by_users)
      .order('created_at DESC')
      .includes([:content_page, :secondary_content_page])
      .includes({ share_comments: [:user], user: [:avatar_attachment] })
    
    # Apply search filter if present
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @feed = @feed.joins(:user).where(
        "content_page_shares.message ILIKE ? OR users.name ILIKE ? OR users.email ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @feed = @feed.limit(25)
  end

  def community
  end

  def global
    @page_title = "What's happening around the world"

    blocked_users    = current_user.blocked_users.pluck(:id)
    blocked_by_users = current_user.blocked_by_users.pluck(:id)

    @feed = ContentPageShare.all
      .where.not(user_id: blocked_users + blocked_by_users)
      .order('created_at DESC')
      .includes([:content_page, :secondary_content_page])
      .includes({ share_comments: [:user], user: [:avatar_attachment] })
    
    # Apply search filter if present
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @feed = @feed.joins(:user).where(
        "content_page_shares.message ILIKE ? OR users.name ILIKE ? OR users.email ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    @feed = @feed.limit(25)
  end

  def set_stream_navbar_color
    @navbar_color = '#CE93D8'
  end

  # For showing a specific piece of content
  def set_stream_navbar_actions
    @navbar_actions = [
      {
        label: 'You & Your Network',
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
