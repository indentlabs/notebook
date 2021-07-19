class ContributorService < Service
  def self.invite_contributor_to_universe universe:, email:
    # First, look up whether a user already exists for this invite
    related_user = User.find_by(email: email.downcase)

    # Create the Contributor object with or without a user
    Contributor.create(
      universe: universe,
      email: email.downcase,
      user: related_user
    )

    # If the user doesn't already have a Notebook.ai account, send them an invite
    if related_user.nil?
      send_invite_email_to(inviter: universe.user, email: email, universe: universe)
    end

    # If the user does have a Notebook.ai account, send them an email letting them know they got added as a contributor
    if related_user
      send_contributor_notice_to(inviter: universe.user, email: email, universe: universe)

      # Also, create a notification letting the user know!
      related_user.notifications.create(
        message_html:     "<div>You have been added as a contributor to the <span class='#{Universe.text_color}'>#{universe.name}</span> universe.</div>",
        icon:             Universe.icon,
        icon_color:       Universe.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.universe_path(universe)
      ) if related_user.present?
    end
  end

  def self.send_invite_email_to inviter:, email:, universe:
    CollaborationMailer.contributor_invitation(
      inviter: inviter,
      invite_email: email,
      universe: universe
    ).deliver_now! if Rails.env.production?
  end

  def self.send_contributor_notice_to inviter:, email:, universe:
    CollaborationMailer.contributor_invitation(
      inviter: inviter,
      invite_email: email,
      universe: universe
    ).deliver_now! if Rails.env.production?
  end
end
