class ModerationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_moderator_access, unless: -> { Rails.env.development? }

  def hub
    @reported_shares_count = ContentPageShareReport.where(approved_at: nil).count
    @pending_forum_posts_count = Thredded::Post.pending_moderation.count
  end

  private

  def require_moderator_access
    unless user_signed_in? && current_user.forum_moderator
      redirect_to root_path, notice: "You don't have permission to view that!"
    end
  end
end
