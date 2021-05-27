class ShareCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_share_comment, only: [:update, :destroy]

  # POST /share_comments
  def create
    @share_comment = ShareComment.new(share_comment_params.merge({ user: current_user }))

    if @share_comment.save
      # Subscribe the commenter to additional comments on this share
      @share_comment.content_page_share.subscribe(@share_comment.user)

      ContentPageShareNotificationJob.perform_later(@share_comment.id)

      redirect_to([@share_comment.content_page_share.user, @share_comment.content_page_share], notice: "Comment posted successfully!");
    else
      redirect_back(fallback_location: @share_comment.content_page_share, notice: "Error submitting comment.")
    end
  end

  # PATCH/PUT /share_comments/1
  # TODO this
  def update
    if user_signed_in? && current_user == @share_comment.user && @share_comment.update(share_comment_params)
      redirect_to @share_comment, notice: 'Share comment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /share_comments/1
  # TODO this
  def destroy
    share = @share_comment.content_page_share
    unless user_signed_in? && (share.user == current_user || @share_comment.user == current_user)
      return raise "Tried to delete comment without authorization"
    end

    @share_comment.destroy
  
    redirect_to [share.user, share], notice: 'Comment was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_share_comment
    @share_comment = ShareComment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def share_comment_params
    params.require(:share_comment).permit(:content_page_share_id, :message)
  end
end
