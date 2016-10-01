class RegistrationsController < Devise::RegistrationsController
  after_filter :add_account

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end

  protected

  def add_account
    if resource.persisted? # user is created successfuly
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
