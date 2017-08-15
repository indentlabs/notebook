class ContributorService < Service
  def self.invite_contributor_to_universe universe:, email:
    # First, look up whether a user already exists for this invite
    related_user = User.find_by(email: email)

    # Create the Contributor object with or without a user
    Contributor.create(
      universe: universe,
      email: email,
      user: related_user
    )

    # If the user doesn't already have a Notebook.ai account, send them an invite
    if related_user.nil?
      send_invite_email_to(email)
    end

    # If the user does have a Notebook.ai account, send them an email letting them know they got added as a contributor
    if related_user
      send_contributor_notice_to(email)
    end
  end

  def self.send_invite_email_to email
    puts "sending invite email"
  end

  def self.send_contributor_notice_to email
    puts "sending contrib notice"
  end
end