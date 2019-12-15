class RegistrationsController < Devise::RegistrationsController
  after_action :add_account, only: [:create]
  after_action :attach_avatar, only: [:update]

  before_action :set_navbar_actions, only: [:edit]
  before_action :set_navbar_color, only: [:edit]

  def new
    super
    if params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def edit
    @sidenav_expansion = 'my account'
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :email_updates)
  end

  def account_update_params
    params.require(:user).permit(
      :name, :email, :username, :password, :password_confirmation, :email_updates, :fluid_preference,
      :bio, :favorite_genre, :favorite_author, :interests, :age, :location, :gender, :forums_badge_text,
      :keyboard_shortcuts_preference, :avatar
    )
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def set_navbar_color
    @navbar_color = '#000000'
  end

  def set_navbar_actions
    @navbar_actions = []
  end

  protected

  def add_account
    # Tie any universe contributor invites with this email to this user
    if resource.persisted?
      Contributor.where(email: resource.email.downcase, user_id: nil).update_all(user_id: resource.id)
    end

    # If the user was created in the last 60 seconds, report it to Slack
    if resource.persisted?
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

  def attach_avatar
    return unless account_update_params.key?('avatar')

    current_user.avatar.attach(account_update_params.fetch('avatar', nil))
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
