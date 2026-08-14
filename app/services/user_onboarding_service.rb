##
# Post-signup housekeeping shared by every account-creation path
# (email/password registration and OAuth signups alike).
class UserOnboardingService < Service
  # Tie any universe contributor invites with this email to this user
  def self.link_pending_contributor_invites(user)
    return unless user.persisted?

    potential_contributor_records = Contributor.where(email: user.email.downcase, user_id: nil)
    return unless potential_contributor_records.any?

    potential_contributor_records.update_all(user_id: user.id)

    # Create a notification letting the user know about each collaboration!
    potential_contributor_records.each do |contributorship|
      user.notifications.create(
        message_html:     "<div>You have been added as a contributor to the <span class='#{Universe.text_color}'>#{contributorship.universe.name}</span> universe.</div>",
        icon:             Universe.icon,
        icon_color:       Universe.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.universe_path(contributorship.universe),
        reference_code:   'contributor-added'
      )
    end
  end

  # Credit the referrer when the new user signed up through a referral link
  def self.record_referral(user, code)
    return unless user.persisted? && code.present?

    referral_code = ReferralCode.where(code: code).first
    return if referral_code.nil?

    Referral.create(
      referrer_id: referral_code.user.id,
      referred_id: user.id,
      associated_code_id: referral_code.id
    )
  end
end
