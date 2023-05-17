class CollaborationMailer < ApplicationMailer
  default from: "collaboration@notebook.ai"

  def contributor_invitation(inviter, invite_email, universe)
    @inviter = inviter
    @universe = universe

    mail(
      to: invite_email,
      subject: "#{@inviter.name} requested your help collaborating on Notebook.ai."
    )
  end
end
