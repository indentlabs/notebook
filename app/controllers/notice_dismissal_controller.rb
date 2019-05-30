class NoticeDismissalController < ApplicationController
  before_action :authenticate_user!

  def dismiss
    current_user.notice_dismissals.find_or_create_by(notice_id: params[:notice_id].to_i)
    redirect_back(fallback_location: dashboard_path, notice: "Notice dismissed! You won't see it again.")
  end
end
