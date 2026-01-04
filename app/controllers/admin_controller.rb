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
  end

  def notifications
    @clicked_notifications = Notification.where.not(viewed_at: nil)
    @notifications = Notification.all.order(:reference_code)

    @codes = Notification.distinct.order('reference_code').pluck(:reference_code)
  end

  def hate
    @posts = Thredded::PrivatePost.order('id DESC').limit(params.fetch(:limit, 500)).includes(:postable)
    @list  = params[:matchlist]
  end

  def spam
    @posts = Thredded::PrivatePost
      .where('content ILIKE ?', "%http%")
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
