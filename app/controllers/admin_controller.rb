class AdminController < ApplicationController
  layout 'admin'
  layout 'application', only: [:unsubscribe, :perform_unsubscribe]

  before_action :authenticate_user!
  before_action :require_admin_access

  def dashboard
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
    @images = ImageUpload.offset(params[:page].to_i * 500).limit(500)
              .includes(:content)
              #.where.not(audited: true)
  end

  def masquerade
    masqueree = User.find_by(id: params[:user_id])
    sign_in masqueree
    redirect_to root_path
  end

  def unsubscribe
  end

  def perform_unsubscribe
    emails = params[:emails].split(/[\r|\n]+/)
    @users = User.where(email: emails)
    @users.update_all(selected_billing_plan_id: 1)
    @users.each do |user|
      SubscriptionService.cancel_all_existing_subscriptions(user)
      UnsubscribedMailer.unsubscribed(user).deliver_now! if Rails.env.production?
    end
  end

  def promos
    @codes = PageUnlockPromoCode.all.includes(:promotions)
  end

  private

  def require_admin_access
    unless user_signed_in? && current_user.site_administrator
      redirect_to root_path, notice: "You don't have permission to view that!"
    end
  end
end
