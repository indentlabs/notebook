class RegistrationsController < Devise::RegistrationsController
  after_filter :add_account, only: [:create]

  def new
    super
    if params[:referral]
      session[:referral] = params[:referral]
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :email_updates)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :username, :password, :password_confirmation, :email_updates, :fluid_preference)
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  protected

  def add_account
    # Tie any universe contributor invites with this email to this user
    if resource.persisted?
      Contributor.where(email: resource.email, user_id: nil).update_all(user_id: resource.id)
    end

    # If the user was created in the last 60 seconds, report it to Slack
    if resource.persisted?
      report_new_account_to_slack resource

      if params[:user].key? :referral_code
        referral_code = ReferralCode.where(code: params[:user][:referral_code]).first

        Referral.create(
          referrer_id: referral_code.user.id,
          referred_id: resource.id,
          associated_code_id: referral_code.id
        ) if referral_code.present?
      end
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
