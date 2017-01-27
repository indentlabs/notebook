class RegistrationsController < Devise::RegistrationsController
  after_filter :add_account

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :email_updates)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password, :email_updates)
  end

  protected

  def add_account
    # If the user was created in the last 30 seconds, report it to Slack
    if resource.persisted? && resource.created_at < Time.now - 30.seconds
      report_new_account_to_slack resource
    end
  end

  def report_new_account_to_slack resource
    return unless Rails.env == 'production'
    slack_hook = ENV['SLACK_HOOK']
    return unless slack_hook

    notifier = Slack::Notifier.new slack_hook,
      channel: '#analytics',
      username: 'tristan'

    notifier.ping "User signed up! :tada: Author #{resource.name} (#{resource.email.split('@').first}@...) :tada: Total authors now: #{User.count} :tada:"
  end
end
