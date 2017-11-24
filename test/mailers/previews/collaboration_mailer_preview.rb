# Preview all emails at http://localhost:3000/rails/mailers/collaboration_mailer
class CollaborationMailerPreview < ActionMailer::Preview
  def contributor_invitation
    CollaborationMailer.contributor_invitation(
      inviter: User.first,
      invite_email: 'andrew@indentlabs.com',
      universe: Universe.first
    )
  end
end
