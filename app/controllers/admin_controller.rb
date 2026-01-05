class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_access, unless: -> { Rails.env.development? }

  def dashboard
    @days = params.fetch(:days, 30).to_i
    @days = 30 unless [1, 7, 30, 90].include?(@days)
    @reports = EndOfDayAnalyticsReport.order('day DESC')
  end

  def hub
    @sidekiq_stats = Sidekiq::Stats.new
  end

  def content_type
    type_whitelist = Rails.application.config.content_types[:all].map(&:name)

    type = params[:type]
    return unless type_whitelist.include?(type)

    @content_type = type.constantize
    @relation_name = type.downcase.pluralize.to_sym
  end

  def universes
  end

  def characters
  end

  def locations
  end

  def items
  end

  def images
    @images = ImageUpload
              .where({ content_type: params.fetch('content_type', nil) }.reject { |k, v| v.nil? })
              .offset(params[:page].to_i * 500).limit(500)
              .includes(:content) #.where.not(audited: true)
              .order('id DESC')
  end

  def masquerade
    masqueree = User.find_by(id: params[:user_id])
    sign_in masqueree
    redirect_to root_path
  end

  def unsubscribe
  end

  def reported_shares
    reported_share_ids = ContentPageShareReport.where(approved_at: nil).pluck(:content_page_share_id)
    @feed = ContentPageShare.where(id: reported_share_ids)
      .order('created_at DESC')
      .includes([:content_page, :user, :share_comments, content_page_share_reports: :user])
      .paginate(page: params[:page], per_page: 100)
  end

  def destroy_share
    share = ContentPageShare.find(params[:id])
    share.destroy
    redirect_to '/admin/shares/reported', notice: 'Share deleted successfully.'
  end

  def destroy_user
    user = User.find(params[:id])
    user.destroy
    redirect_to '/admin/shares/reported', notice: 'User and all their content deleted.'
  end

  def dismiss_share_reports
    share = ContentPageShare.find(params[:id])
    share.content_page_share_reports.update_all(approved_at: Time.current)
    redirect_to '/admin/shares/reported', notice: 'Reports dismissed.'
  end
  
  def churn
    @timespan = params[:timespan]
    @timespan = nil unless %w[30 90 365].include?(@timespan)

    @start_date = @timespan.present? ? @timespan.to_i.days.ago.to_date : nil
  end

  def attributes
    @total_attributes = AttributeField.count
    @total_users = AttributeField.distinct.count(:user_id)
    @avg_per_user = @total_users > 0 ? (@total_attributes.to_f / @total_users).round(1) : 0

    @by_content_type = AttributeCategory
      .joins(:attribute_fields)
      .group(:entity_type)
      .count
  end

  def notifications
    # Pre-aggregate stats by reference_code in a single query (top 50 by volume)
    @code_stats = Notification
      .select(
        'reference_code',
        'COUNT(*) as total_count',
        'COUNT(viewed_at) as clicked_count'
      )
      .group(:reference_code)
      .order('total_count DESC')
      .limit(50)

    # Get list of codes for the search autocomplete
    @codes = Notification.distinct.pluck(:reference_code).compact

    # Overall stats using database aggregation
    @total_count = Notification.count
    @clicked_count = Notification.where.not(viewed_at: nil).count

    # Time-to-click stats calculated in SQL (avoid loading all rows into memory)
    # Use database-specific syntax for date diff calculation
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      @avg_seconds = Notification
        .where.not(viewed_at: nil)
        .where.not(happened_at: nil)
        .average('EXTRACT(EPOCH FROM (viewed_at - happened_at))')
        &.to_i
    else
      # SQLite: use strftime to calculate seconds
      @avg_seconds = Notification
        .where.not(viewed_at: nil)
        .where.not(happened_at: nil)
        .average("(julianday(viewed_at) - julianday(happened_at)) * 86400")
        &.to_i
    end

    # Pre-aggregate link stats (top 50 by volume)
    @link_stats = Notification
      .where.not(passthrough_link: [nil, ''])
      .select(
        'passthrough_link',
        'COUNT(*) as total_count',
        'COUNT(viewed_at) as clicked_count'
      )
      .group(:passthrough_link)
      .order('total_count DESC')
      .limit(50)
  end

  def notification_reference
    @reference_code = params[:reference_code]
    @notifications = Notification.where(reference_code: @reference_code)
    @clicked_notifications = @notifications.where.not(viewed_at: nil)

    # Basic counts
    @total_sent = @notifications.count
    @total_clicked = @clicked_notifications.count
    @click_rate = @total_sent > 0 ? (@total_clicked / @total_sent.to_f * 100).round(1) : 0
    @unique_users = @notifications.distinct.count(:user_id)

    # Time to click calculations
    @clicked_with_times = @clicked_notifications.where.not(happened_at: nil)
    if @clicked_with_times.any?
      time_diffs = @clicked_with_times.map { |n| (n.viewed_at - n.happened_at).to_i }
      @avg_seconds = time_diffs.sum / time_diffs.count
      sorted_diffs = time_diffs.sort
      @median_seconds = sorted_diffs[sorted_diffs.length / 2]
      @fastest_seconds = sorted_diffs.first
      @slowest_seconds = sorted_diffs.last
    end

    # Date range
    @first_notification = @notifications.order(:created_at).first
    @last_notification = @notifications.order(created_at: :desc).first

    # Sample message
    @sample_notification = @notifications.where.not(message_html: [nil, '']).order(created_at: :desc).first
  end

  def hate
    @posts = Thredded::PrivatePost.order('id DESC').limit(params.fetch(:limit, 500)).includes(:postable)
    @list  = params[:matchlist]
  end

  def spam
    @posts = Thredded::PrivatePost
      .where(Thredded::PrivatePost.arel_table[:content].matches('%http%'))
      .order('id DESC')
      .limit(params.fetch(:limit, 500))
      .includes(:postable)


    # @posts = Thredded::PrivatePost.where('content ILIKE ?', "%http%").order('id DESC').limit(5).includes(:postable)
  end

  def perform_unsubscribe
    emails = params[:emails].split(/[\r|\n]+/)
    @users = User.where(email: emails)
    @users.each do |user|
      if user.on_premium_plan?
        SubscriptionService.cancel_all_existing_subscriptions(user)
        UnsubscribedMailer.unsubscribed(user).deliver_now! if Rails.env.production?
      end
    end
    @users.update_all(selected_billing_plan_id: 1)
  end

  def promos
    @codes = PageUnlockPromoCode.all.includes(:promotions)
  end
end
