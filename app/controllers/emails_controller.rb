class EmailsController < ApplicationController
  def one_click_unsubscribe
    user = User.find_by(secure_code: params[:code])

    user.update email_updates: false
    render text: "You have been successfully unsubscribed from all emails."
  end
end
