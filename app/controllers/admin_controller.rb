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

    # Get list of codes for search autocomplete (use top 50 codes already fetched, not all codes)
    @codes = @code_stats.map(&:reference_code).compact

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

    # Pre-calculate chart data (last 12 months) - avoid running in view
    twelve_months_ago = 12.months.ago
    @sent_by_month = Notification
      .where('created_at > ?', twelve_months_ago)
      .group_by_month(:created_at)
      .count

    @clicked_by_month = Notification
      .where.not(viewed_at: nil)
      .where('created_at > ?', twelve_months_ago)
      .group_by_month(:created_at)
      .count
  end

  def notification_reference
    @reference_code = params[:reference_code]
    @notifications = Notification.where(reference_code: @reference_code)

    # Basic counts (all done in SQL)
    @total_sent = @notifications.count
    @total_clicked = @notifications.where.not(viewed_at: nil).count
    @click_rate = @total_sent > 0 ? (@total_clicked / @total_sent.to_f * 100).round(1) : 0
    @unique_users = @notifications.distinct.count(:user_id)

    # Time to click calculations - done entirely in SQL (avoid loading all rows into Ruby)
    clicked_with_times = @notifications.where.not(viewed_at: nil).where.not(happened_at: nil)

    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      # PostgreSQL: use EXTRACT and PERCENTILE_CONT for all stats in one query
      time_stats = clicked_with_times.select(
        'COUNT(*) as stat_count',
        'AVG(EXTRACT(EPOCH FROM (viewed_at - happened_at)))::integer as avg_seconds',
        'MIN(EXTRACT(EPOCH FROM (viewed_at - happened_at)))::integer as min_seconds',
        'MAX(EXTRACT(EPOCH FROM (viewed_at - happened_at)))::integer as max_seconds',
        'PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (viewed_at - happened_at)))::integer as median_seconds'
      ).take

      if time_stats && time_stats.stat_count.to_i > 0
        @avg_seconds = time_stats.avg_seconds
        @median_seconds = time_stats.median_seconds
        @fastest_seconds = time_stats.min_seconds
        @slowest_seconds = time_stats.max_seconds
      end
    else
      # SQLite: no PERCENTILE_CONT, calculate separately
      @avg_seconds = clicked_with_times
        .average("(julianday(viewed_at) - julianday(happened_at)) * 86400")
        &.to_i

      @fastest_seconds = clicked_with_times
        .minimum("(julianday(viewed_at) - julianday(happened_at)) * 86400")
        &.to_i

      @slowest_seconds = clicked_with_times
        .maximum("(julianday(viewed_at) - julianday(happened_at)) * 86400")
        &.to_i

      # For median in SQLite, we need a subquery approach (approximation using LIMIT/OFFSET)
      total_clicked_with_times = clicked_with_times.count
      if total_clicked_with_times > 0
        median_row = clicked_with_times
          .select("(julianday(viewed_at) - julianday(happened_at)) * 86400 as diff_seconds")
          .order('diff_seconds')
          .offset(total_clicked_with_times / 2)
          .limit(1)
          .first
        @median_seconds = median_row&.diff_seconds&.to_i
      end
    end

    # Date range (single row queries with index)
    @first_notification = @notifications.order(:created_at).limit(1).first
    @last_notification = @notifications.order(created_at: :desc).limit(1).first

    # Sample message
    @sample_notification = @notifications.where.not(message_html: [nil, '']).order(created_at: :desc).limit(1).first

    # Pre-aggregate link stats for this reference code (avoid N+1 in view)
    @link_stats = @notifications
      .where.not(passthrough_link: [nil, ''])
      .select(
        'passthrough_link',
        'COUNT(*) as total_count',
        'COUNT(viewed_at) as clicked_count'
      )
      .group(:passthrough_link)
      .order('total_count DESC')
      .limit(50)

    # Pre-calculate chart data (avoid running queries in view)
    @sent_by_month = @notifications.group_by_month(:created_at).count
    @clicked_by_month = @notifications.where.not(viewed_at: nil).group_by_month(:created_at).count

    # Flag for whether we have time stats to display
    @has_time_stats = @avg_seconds.present?
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
