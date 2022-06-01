class UsersController < ApplicationController
  layout 'tailwind'

  before_action :set_user, only: [:show, :followers, :following]

  def index
    redirect_to new_session_path(User)
  end

  def show
    @sidenav_expansion = 'community'

    @feed = ContentPageShare.where(user_id: @user.id)
      .order('created_at DESC')
      .includes([:content_page, :secondary_content_page, :user, :share_comments])
      .limit(100)

    @content = @user.public_content.select { |type, list| list.any? }
    @tabs    = @content.keys
  
    @favorite_content = @user.favorite_page_type? ? @user.send(@user.favorite_page_type.downcase.pluralize).is_public : []
    @stream           = @user.recent_content_list(limit: 20)
  end

  Rails.application.config.content_types[:all].each do |content_type|
    content_type_name = content_type.name.downcase.pluralize.to_sym # :characters, :items, etc
    define_method content_type_name do
      set_user

      # We double up on the same returns from set_user here since we're calling set_user manually instead of a before_action
      return if @user.nil?
      return if @user.private_profile?

      @random_image_including_private_pool_cache = ImageUpload.where(
        user_id: @user.id,
      ).group_by { |image| [image.content_type, image.content_id] }
      
      @content_type = content_type
      @content_list = @user.send(content_type_name).is_public.order(:name)

      render :content_list
    end
  end

  def delete_my_account # :(
    unless user_signed_in?
      redirect_to(root_path, notice: "You must be signed in to do that!")
      return
    end

    # Make sure the user is set to Starter on Stripe so we don't keep charging them
    stripe_customer = Stripe::Customer.retrieve(current_user.stripe_customer_id)
    stripe_subscription = stripe_customer.subscriptions.data[0]
    if stripe_subscription
      stripe_subscription.plan = 'starter'
      stripe_subscription.save
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
  end

  def following
  end

  private

  def set_user
    @user    = User.find_by(user_params)
    return redirect_to(root_path, notice: 'That user does not exist.') if @user.nil?
    return redirect_to(root_path, notice: 'That user has chosen to hide their profile.') if @user.private_profile?

    @accent_color     = @user.favorite_page_type_color
    @accent_icon      = @user.favorite_page_type_icon
  end

  def user_params
    params.permit(:id, :username)
  end
end
