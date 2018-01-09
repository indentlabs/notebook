class InvoicesMailer < ApplicationMailer
  default from: "billing@notebook.ai"

  def dispatch_invoice(user_id)
    @user = User.find_by(id: user_id)
    mail(
      to: @user.email,
      subject: "Your Invoice for Notebook.ai."
    )
  end

  def problem_with_payment(user_id)
    @user = User.find_by(id: user_id)
    mail(
      to: @user.email,
      subject: "Payment Issue in Notebook.ai."
    )
  end

  def downgraded_to_starter(user_id)
    @user = User.find_by(id: user_id)
    mail(
      to: @user.email,
      subject: "You have been downgraded to starter plan on Notebook.ai."
    )
  end
end
