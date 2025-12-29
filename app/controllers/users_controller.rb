class UsersController < ApplicationController
  before_action :set_user, only: [:show, :followers, :following, :tag]

  def index
    redirect_to new_session_path(User)
  end

  def show
    @sidenav_expansion = 'community'

    # Load all profile data
    load_user_content
    load_user_activity
    load_user_social_data
    load_user_collections
    load_user_statistics
  end

  Rails.application.config.content_types[:all].each do |content_type|
    content_type_name = content_type.name.downcase.pluralize.to_sym # :characters, :items, etc
    define_method content_type_name do
      set_user

      # We double up on the same returns from set_user here since we're calling set_user manually instead of a before_action
      return if @user.nil?
      return if @user.private_profile?

      # Optimized: Only load images for content that will be displayed
      @content_type = content_type
      @content_list = @user.send(content_type_name)
                           .includes(:page_tags, :image_uploads)
                           .is_public
                           .order(:name)
                           .paginate(page: params[:page], per_page: 20)
      
      # Only load public images for the content being displayed
      content_ids = @content_list.pluck(:id)
      @random_image_including_private_pool_cache = ImageUpload
        .where(user_id: @user.id, content_type: content_type.name, content_id: content_ids)
        .where(privacy: 'public')
        .group_by { |image| [image.content_type, image.content_id] }

      # Optimized: Use content_ids we already have
      @saved_basil_commissions = BasilCommission
        .where(entity_type: content_type.name, entity_id: content_ids)
        .where.not(saved_at: nil)
        .group_by { |commission| [commission.entity_type, commission.entity_id] }

      render :content_list
    end
  end

  # Silent timezone auto-update for legacy users (remove after Jan 31, 2026)
  def update_timezone
    return head :unauthorized unless user_signed_in?

    timezone = params[:time_zone]

    if ActiveSupport::TimeZone[timezone].present?
      current_user.update(time_zone: timezone)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def delete_my_account # :(
    unless user_signed_in?
      redirect_to(root_path, notice: "You must be signed in to do that!")
      return
    end

    # Make sure the user is set to Starter on Stripe so we don't keep charging them
    stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    
    # Use safe navigation to handle customers without subscriptions
    subscriptions = stripe_customer.subscriptions&.data || []
    stripe_subscription = subscriptions.first
    if stripe_subscription
      # Update subscription to starter plan using modern API
      Stripe::Subscription.modify(stripe_subscription.id, {
        items: [{
          id: stripe_subscription.items.data[0].id,
          price: 'starter'
        }]
      })
    end

    report_user_deletion_to_slack(current_user)

    current_user.avatar.purge
    
    # Immediately mark the user as deleted and inactive
    current_user.update(deleted_at: DateTime.current)

    # Destroy the user and all of its content
    # TODO this can take quite a while for active users, so it should be moved to a background job
    current_user.destroy!

    redirect_to(root_path, notice: 'Your account has been deleted. We will miss you greatly!')
  end

  def report_user_deletion_to_slack user
    return unless Rails.env == 'production'
    slack_hook = ENV['SLACK_HOOK']
    return unless slack_hook

    notifier = Slack::Notifier.new slack_hook,
      channel: '#analytics',
      username: 'tristan'

    notifier.ping ":bomb: :bomb: :bomb: #{user.email.split('@').first}@ (##{user.id}) just deleted their account."
  end

  def followers
    @followers = @user.followed_by_users
                      .includes(:avatar_attachment, :thredded_user_detail)
                      .paginate(page: params[:page], per_page: 100)
  end

  def following
    @following = @user.followed_users
                      .includes(:avatar_attachment, :thredded_user_detail)
                      .paginate(page: params[:page], per_page: 100)
  end
  
  def tag
    @tag_slug = params[:tag_slug]
    @tag = PageTag.find_by(user_id: @user.id, slug: @tag_slug)
    
    if @tag.nil?
      redirect_url = @user.username.present? ? profile_by_username_path(username: @user.username) : user_path(@user)
      return redirect_to(redirect_url, notice: 'That tag does not exist.', status: :not_found)
    end

    # Find all public content with this tag
    @tagged_content = []
    
    # Go through each content type and find items with this tag
    Rails.application.config.content_types[:all].each do |content_type|
      content_pages = content_type.joins(:page_tags)
                              .where(privacy: 'public')
                              .where(user_id: @user.id)
                              .where(page_tags: { slug: @tag_slug })
                              .order(:name)

      @tagged_content << {
        type: content_type.name,
        icon: content_type.icon,
        color: content_type.color,
        content: content_pages
      } if content_pages.any?
    end
    
    # Add documents and timelines if they have the tag
    # Handle documents separately since they don't use the common content type structure
    documents = Document.joins(:page_tags)
                        .where(privacy: 'public')
                        .where(user_id: @user.id)
                        .where(page_tags: { slug: @tag_slug })
                        .order(:title) # Documents use 'title' instead of 'name'
                        
    @tagged_content << {
      type: 'Document',
      icon: 'description',
      color: 'blue',
      content: documents
    } if documents.any?
    
    # Handle timelines separately since they don't use the common content type structure
    timelines = Timeline.joins(:page_tags)
                        .where(privacy: 'public')
                        .where(user_id: @user.id)
                        .where(page_tags: { slug: @tag_slug })
                        .order(:name)
                        
    @tagged_content << {
      type: 'Timeline',
      icon: 'timeline',
      color: 'blue',
      content: timelines
    } if timelines.any?
    
    # Get images for content cards
    @random_image_including_private_pool_cache = ImageUpload.where(
      user_id: @user.id,
    ).group_by { |image| [image.content_type, image.content_id] }
    
    # Collect all content IDs and types for fetching basil commissions
    basil_entity_types = []
    basil_entity_ids = []

    @tagged_content.each do |content_group|
      content_group[:content].each do |content|
        basil_entity_types << content.class.name
        basil_entity_ids << content.id
      end
    end

    # Initialize @saved_basil_commissions if there are any content items
    if basil_entity_types.any?
      @saved_basil_commissions = BasilCommission.where(
        entity_type: basil_entity_types,
        entity_id: basil_entity_ids
      ).where.not(saved_at: nil)
      .group_by { |commission| [commission.entity_type, commission.entity_id] }
    end
    
    @sidenav_expansion = 'community'
  end

  private

  def set_user
    @user    = User.find_by(user_params)
    return redirect_to(root_path, notice: 'That user does not exist.', status: :not_found) if @user.nil?
    return redirect_to(root_path, notice: 'That user has chosen to hide their profile.') if @user.private_profile?
    return redirect_to(root_path, notice: 'That user has had their profile hidden.') if @user.thredded_user_detail.moderation_state == 'blocked'

    @accent_color     = @user.favorite_page_type_color
    @accent_icon      = @user.favorite_page_type_icon
  end

  def user_params
    params.permit(:id, :username)
  end
  
  # Data loading methods for profile sections
  
  def load_user_content
    @content = @user.public_content.select { |type, list| list.any? }
    @tabs = @content.keys
    @popular_tags = get_popular_public_tags_for_user(@user)
    @favorite_content = @user.favorite_page_type? ? @user.send(@user.favorite_page_type.downcase.pluralize).is_public : []
    
    # Get featured universes (top 3 most recently updated)
    @featured_universes = @user.universes.is_public.order(updated_at: :desc).limit(3) if @user.respond_to?(:universes)
    @featured_universes ||= []
  end
  
  def load_user_activity
    # Optimized: Use joins to filter at database level
    @feed = ContentPageShare
      .includes(:content_page, :share_comments)
      .where(user_id: @user.id)
      .where(privacy: 'public')
      .order('created_at DESC')
      .limit(100)
    
    # Optimized: Get public content directly
    @stream = @user.recent_public_content_list(limit: 20)
    
    # Skip recent edits - we don't want to show "made an edit" activities
    @recent_edits = []
    
    # Forum activity (if Thredded is available)
    if defined?(Thredded::Post)
      @recent_forum_posts = Thredded::Post
        .includes(:postable, :messageboard)
        .where(user_id: @user.id, moderation_state: 'approved')
        .order(created_at: :desc)
        .limit(10)
    else
      @recent_forum_posts = []
    end
    
    # Combine all activities for unified timeline (excluding edits)
    @unified_activity = build_unified_activity_timeline
  end
  
  def load_user_social_data
    # Optimized: Use counter caches if available, fallback to count
    @followers_count = @user.respond_to?(:followers_count) ? @user.followers_count : @user.followed_by_users.count
    @following_count = @user.respond_to?(:following_count) ? @user.following_count : @user.followed_users.count
    
    # Optimized: Use includes to prevent N+1
    @followers = User.joins(:user_followings)
                     .where(user_followings: { followed_user_id: @user.id })
                     .includes(:avatar_attachment)
                     .limit(12)
    @following = @user.followed_users.includes(:avatar_attachment).limit(12)
    
    # Optimized: Check follows and blocks efficiently
    if user_signed_in?
      @is_following = UserFollowing.exists?(user_id: current_user.id, followed_user_id: @user.id)
      @is_blocked = UserBlocking.exists?(user_id: current_user.id, blocked_user_id: @user.id)
    else
      @is_following = false
      @is_blocked = false
    end
  end
  
  def load_user_collections
    # Collections user maintains (only public ones visible on profile)
    @maintained_collections = @user.page_collections.where(privacy: 'public').order(updated_at: :desc)
    
    # Collections user is published in
    @published_in_collections = @user.published_in_page_collections.limit(20)
  end
  
  def load_user_statistics
    # Calculate user statistics
    @total_public_pages = @content.values.map(&:count).sum
    @total_words = calculate_total_word_count
    @join_date = @user.created_at
    @last_active = [@user.updated_at, @user.current_sign_in_at].compact.max
    
    # Activity streak
    @activity_streak = calculate_activity_streak
  end
  
  def calculate_total_word_count
    total = 0
    @content.each do |content_type, pages|
      pages.each do |page|
        total += page.cached_word_count if page.respond_to?(:cached_word_count) && page.cached_word_count
      end
    end
    total
  end
  
  def calculate_activity_streak
    # Calculate consecutive days of activity (only from content shares since edits are excluded)
    activity_dates = @feed.map(&:created_at).map(&:to_date).uniq.sort.reverse
    
    streak = 0
    current_date = Date.current
    
    activity_dates.each do |date|
      if date == current_date
        streak += 1
        current_date -= 1.day
      else
        break
      end
    end
    
    streak
  end
  
  def build_unified_activity_timeline
    activities = []
    
    # Add content shares
    @feed.each do |share|
      activities << {
        type: 'share',
        created_at: share.created_at,
        data: share
      }
    end
    
    # Add recent edits
    @recent_edits.each do |edit|
      activities << {
        type: 'edit',
        created_at: edit.created_at,
        data: edit
      }
    end
    
    # Add forum posts
    @recent_forum_posts.each do |post|
      activities << {
        type: 'forum_post',
        created_at: post.created_at,
        data: post
      }
    end
    
    # Sort by most recent first
    activities.sort_by { |activity| activity[:created_at] }.reverse.first(20)
  end

  # Get most popular tags for a user's public content
  def get_popular_public_tags_for_user(user, limit: 10)
    # Find page tags attached to public content
    public_page_tags = []
    
    # For each content type, find public pages with tags
    Rails.application.config.content_types[:all].each do |content_type|
      # Skip if a user has no pages of this type
      next unless user.respond_to?(content_type.name.downcase.pluralize)
      
      # Get all public pages of this content type
      public_pages = user.send(content_type.name.downcase.pluralize).is_public
      
      # Skip if there are no public pages
      next if public_pages.empty?
      
      # Find all page tags for these pages
      tag_ids = PageTag.where(page_type: content_type.name, page_id: public_pages.pluck(:id)).pluck(:id)
      public_page_tags.concat(tag_ids) if tag_ids.any?
    end
    
    # Also include Document and Timeline tags if they're public
    public_documents = user.documents.where(privacy: 'public')
    if public_documents.any?
      document_tag_ids = PageTag.where(page_type: 'Document', page_id: public_documents.pluck(:id)).pluck(:id)
      public_page_tags.concat(document_tag_ids) if document_tag_ids.any?
    end
    
    public_timelines = user.timelines.where(privacy: 'public')
    if public_timelines.any?
      timeline_tag_ids = PageTag.where(page_type: 'Timeline', page_id: public_timelines.pluck(:id)).pluck(:id)
      public_page_tags.concat(timeline_tag_ids) if timeline_tag_ids.any?
    end
    
    # If we have tags, find the most popular ones
    return [] if public_page_tags.empty?
    
    # Get the actual tags
    PageTag.where(id: public_page_tags)
           .select('tag, slug, COUNT(*) as usage_count')
           .group(:tag, :slug)
           .order('usage_count DESC')
           .limit(limit)
  end
end
