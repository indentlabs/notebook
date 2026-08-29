class RegistrationsController < Devise::RegistrationsController
  after_action :add_account, only: [:create]
  after_action :attach_avatar, only: [:update]

  prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy, :password]
  before_action :set_navbar_actions, only: [:edit, :preferences, :more_actions]
  before_action :set_navbar_color, only: [:edit, :preferences, :more_actions]

  layout :determine_layout

  def determine_layout
    if action_name.in?(['new', 'create'])
      'tailwind/landing'
    else
      'application'
    end
  end

  def new
    super
    
    if params[:referral]
      session[:referral] = params[:referral]
    end
  end

  def edit
    @sidenav_expansion = 'my account'

    @page_title = "My settings"
  end

  def preferences
    @sidenav_expansion = 'my account'

    @page_title = "My preferences"
  end

  def more_actions
    @sidenav_expansion = 'my account'

    @page_title = "More settings"
  end
  
  def password
    @sidenav_expansion = 'my account'
    
    @page_title = "Change Password"
    
    # Set the resource for the form
    self.resource = current_user
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :email_updates)
  end

  def account_update_params
    params.require(:user).permit(
      :name, :email, :username, :password, :password_confirmation, :email_updates,
      :bio, :favorite_genre, :favorite_author, :interests, :age, :location, :gender, :forums_badge_text,
      :keyboard_shortcuts_preference, :avatar, :favorite_book, :website, :inspirations, :other_names,
      :favorite_quote, :occupation, :favorite_page_type, :dark_mode_enabled, :notification_updates,
      :community_features_enabled, :private_profile, :time_zone
    )
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    request.referrer || edit_user_registration_path(resource)
  end

  def set_navbar_color
    @navbar_color = '#000000'
  end

  def set_navbar_actions
    @navbar_actions = [{
      label: "About you",
      href: edit_user_registration_path
    }, {
      label: "Preferences",
      href: user_preferences_path(current_user)
    }, {
      label: "More...",
      href: user_more_actions_path(current_user)
    }]
  end

  protected

  def add_account
    UserOnboardingService.link_pending_contributor_invites(resource)

    if params[:user].key? :referral_code
      UserOnboardingService.record_referral(resource, params[:user][:referral_code])
    end
  end

  def attach_avatar
    return unless account_update_params.key?('avatar')

    current_user.avatar.purge
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
