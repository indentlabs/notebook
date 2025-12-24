class ContentPageSharesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_content_page_share, only: [
    :show, :edit, :update, :destroy, 
    :follow, :unfollow, :report
  ]
  before_action :load_recent_forum_topics, only: [:show]

  # GET /content_page_shares
  def index
    @shares = ContentPageShare.all
  end

  # GET /content_page_shares/1
  def show
    @page_title = "#{@share.user.display_name}'s #{@share.content_page_type} shared"

    @sidenav_expansion = 'community'
    
    # Set up follow/block status for the share creator
    if current_user
      @is_following = current_user.user_followings.exists?(followed_user: @share.user)
      @is_blocked = current_user.user_blockings.exists?(blocked_user: @share.user)
    else
      @is_following = false
      @is_blocked = false
    end
  end

  # GET /content_page_shares/new
  def new
    @share = ContentPageShare.new
  end

  # GET /content_page_shares/1/edit
  def edit
  end

  # POST /content_page_shares
  def create
    @share = ContentPageShare.new(content_page_share_params)

    if @share.save
      @share.content_page.update(privacy: 'public')

      # Notify the content creator if they're different from the sharer
      content_owner = @share.content_page.user
      if content_owner != current_user && content_owner.notification_updates?
        content_type_name = @share.content_page.class.name.downcase
        content_type_color = @share.content_page.class.respond_to?(:color) ? @share.content_page.class.color : 'bg-blue-500'

        content_owner.notifications.create(
          message_html: "🎉 <strong>#{current_user.display_name}</strong> shared your <span class='#{content_type_color} text-white px-1 rounded'>#{content_type_name}</span> <strong>#{@share.content_page.name}</strong> with the community!",
          icon: 'campaign',
          icon_color: 'green',
          happened_at: DateTime.current,
          passthrough_link: user_content_page_share_path(@share.user, @share),
          reference_code: 'content-shared-by-other'
        )
      end

      redirect_to [@share.user, @share], notice: 'Thanks for sharing!'
    else
      raise @share.errors.inspect
    end
  end

  def follow
    @share.content_page_share_followings.find_or_create_by(user_id: current_user.id)
    redirect_to [@share.user, @share], notice: 'You will now receive notifications about this share.'
  end

  def unfollow
    @share.content_page_share_followings.find_by(user_id: current_user.id).try(:destroy)
    redirect_to [@share.user, @share], notice: 'You will no longer receive notifications about this share.'
  end

  def report
    @share.content_page_share_reports.create(user_id: current_user.id)
    redirect_to stream_path, notice: "That share has been reported to site administration. Thank you!"
  end

  # PATCH/PUT /content_page_shares/1
  def update
    if @share.update(content_page_share_params)
      redirect_to @share, notice: 'Content page share was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /content_page_shares/1
  def destroy
    @share.destroy
    redirect_to(content_page_shares_url, notice: 'The share was successfully deleted.')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_page_share
    @share = ContentPageShare.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def content_page_share_params
    {
      content_page_type: params.require(:content_page_share).require(:content_page).split('-').first,
      content_page_id:   params.require(:content_page_share).require(:content_page).split('-').second,
      message:           params.require(:content_page_share).permit(:message).fetch('message', ''),
      user_id:           current_user.id,
      shared_at:         DateTime.current
    }
  end

  def load_recent_forum_topics
    # Get the 5 most recent forum posts and their topics
    recent_posts = Thredded::Post.joins(:topic)
                                 .where(deleted_at: nil)
                                 .order(created_at: :desc)
                                 .limit(10)
                                 .includes(:topic, :user)

    # Get unique topics from recent posts, limited to 5
    @recent_forum_topics = recent_posts.map(&:topic)
                                      .uniq { |topic| topic.id }
                                      .first(5)
  rescue => e
    Rails.logger.error "Error loading recent forum topics: #{e.message}"
    @recent_forum_topics = []
  end
end