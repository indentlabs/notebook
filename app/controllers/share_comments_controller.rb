class ShareCommentsController < ApplicationController
  before_action :set_share_comment, only: [:show, :edit, :update, :destroy]

  # GET /share_comments
  def index
    @share_comments = ShareComment.all
  end

  # GET /share_comments/1
  def show
  end

  # GET /share_comments/new
  def new
    @share_comment = ShareComment.new
  end

  # GET /share_comments/1/edit
  def edit
  end

  # POST /share_comments
  def create
    @share_comment = ShareComment.new(share_comment_params.merge({user: current_user}))

    if @share_comment.save
      # Notification for share owner
      @share_comment.content_page_share.user.notifications.create(
        message_html:     "<div><span class='#{User.color}-text'>#{@share_comment.user.display_name}</span> commented on your shared #{@share_comment.content_page_share.content_page.class.name.downcase} <span class='#{@share_comment.content_page_share.content_page.class.color}-text'>#{@share_comment.content_page_share.content_page.name}</span>.</div>",
        icon:             @share_comment.content_page_share.content_page.class.icon,
        icon_color:       @share_comment.content_page_share.content_page.class.color,
        happened_at:      DateTime.current,
        passthrough_link: Rails.application.routes.url_helpers.user_content_page_share_path(
          id:      @share_comment.content_page_share.id,
          user_id: @share_comment.content_page_share.user_id
        )
      ) unless @share_comment.user == @share_comment.content_page_share.user

      redirect_back(fallback_location: @share_comment.content_page_share, notice: "Comment posted successfully.")
    else
      render :new
    end
  end

  # PATCH/PUT /share_comments/1
  def update
    if @share_comment.update(share_comment_params)
      redirect_to @share_comment, notice: 'Share comment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /share_comments/1
  def destroy
    @share_comment.destroy
    redirect_to share_comments_url, notice: 'Share comment was successfully destroyed.'
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
