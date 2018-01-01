class UsersController < ApplicationController
  def index
    redirect_to new_session_path(User)
  end

  def show
    @user = User.find(params[:id])

    @content = @user.public_content.select { |type, list| list.any? }
    @tabs = @content.keys
    @stream = ContentChangeEvent.where(user_id: @user.id).order('id desc').limit(100)

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(@user.id, 'viewed profile', {
      'sharing any content': @user.public_content_count != 0
    }) if Rails.env.production?
  end

  #todo use the new constants here
  [
    :characters, :locations, :items, :creatures, :races, :religions, :groups, :magics, :languages, :floras, :scenes, :countries, :towns, :landmarks, :universes
  ].each do |content_type_name|
    define_method content_type_name do
      @content_type = content_type_name.to_s.singularize.capitalize.constantize

      @user = User.find(params[:id])
      @content_list = @user.send(content_type_name).is_public.order(:name)

      render :content_list
    end
  end

  def delete_my_account # :(
    unless user_signed_in?
      redirect_to root_path
      return
    end

    # Make sure the user is set to Starter on Stripe so we don't keep charging them
    stripe_customer = Stripe::Customer.retrieve current_user.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.data[0]
    stripe_subscription.plan = 'starter'
    stripe_subscription.save

    report_user_deletion_to_slack current_user

    current_user.really_destroy!
    redirect_to root_path, notice: 'Your account has been deleted. We will miss you greatly!'
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
end
