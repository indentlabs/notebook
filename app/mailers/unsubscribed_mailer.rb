class UnsubscribedMailer < ApplicationMailer
  default from: "noreply@notebook.ai"

  def unsubscribed(user)
    @user_name  = user.name.presence || 'worldbuilder'
    @user_email = user.email

    mail(
      to: @user_email,
      subject: "Update your payment method to keep your Notebook.ai Premium features"
    )
  end
end
