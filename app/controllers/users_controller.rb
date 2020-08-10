class UsersController < ApplicationController
  def index
    redirect_to new_session_path(User)
  end

  def show
    @sidenav_expansion = 'community'

    @user    = User.find_by(user_params)
    return redirect_to(root_path, notice: 'That user does not exist.') if @user.nil?
    return redirect_to(root_path, notice: 'That user does not exist.') if @user.private_profile?

    @feed = ContentPageShare.where(user_id: @user.id)
      .order('created_at DESC')
      .includes([:content_page, :user, :share_comments])
      .limit(100)

    @content = @user.public_content.select { |type, list| list.any? }
    @tabs    = @content.keys
  
    @accent_color     = @user.favorite_page_type_color
    @accent_icon      = @user.favorite_page_type_icon
    @favorite_content = @user.favorite_page_type? ? @user.send(@user.favorite_page_type.downcase.pluralize).is_public : []

    # todo this is really bad and needs redone/improved
    # @stream  = @user.content_change_events.order('updated_at desc').limit(100).group_by do |cce|
    #   next if cce.content.nil?
    #   if cce.content.is_a?(Attribute)
    #     next if cce.content.entity.nil?
    #     cce.content.entity.id
    #   else
    #     cce.content.id
    #   end
    # end

    @stream = @user.recent_content_list(limit: 20)
    
    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(@user.id, 'viewed profile', {
      'sharing any content': @user.public_content_count != 0
    }) if Rails.env.production?
  end

  Rails.application.config.content_types[:all].each do |content_type|
    content_type_name = content_type.name.downcase.pluralize.to_sym # :characters, :items, etc
    define_method content_type_name do
      @content_type = content_type
      @user = User.find_by(id: params[:id])
      return redirect_to(root_path, notice: "This user does not exist") unless @user.present?
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
    @user    = User.find_by(user_params)
    @accent_color     = @user.favorite_page_type_color
    @accent_icon      = @user.favorite_page_type_icon
  end

  def following
    @user    = User.find_by(user_params)
    @accent_color     = @user.favorite_page_type_color
    @accent_icon      = @user.favorite_page_type_icon
  end

  private

  def user_params
    # todo is this used anywhere?
    params.permit(:id, :username)
  end
end
