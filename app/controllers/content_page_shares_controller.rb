class ContentPageSharesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_page_share, only: [:show, :edit, :update, :destroy, :follow, :unfollow]

  # GET /content_page_shares
  def index
    @shares = ContentPageShare.all
  end

  # GET /content_page_shares/1
  def show
    @sidenav_expansion = 'community'
  end

  # GET /content_page_shares/new
  def new
    @share = ContentPageShare.new
  end

  # GET /content_page_shares/1/edit
  def edit
  end

  # POST /content_page_shares
  def create
    @share = ContentPageShare.new(content_page_share_params)

    if @share.save
      redirect_to [@share.user, @share], notice: 'Content page share was successfully created.'
    else
      render :new
    end
  end

  def follow
    @share.content_page_share_followings.find_or_create_by(user_id: current_user.id)
    redirect_to [@share.user, @share], notice: 'You will now receive notifications about this share.'
  end

  def unfollow
    @share.content_page_share_followings.find_by(user_id: current_user.id).try(:destroy)
    redirect_to [@share.user, @share], notice: 'You will no longer receive notifications about this share.'
  end

  # PATCH/PUT /content_page_shares/1
  def update
    if @share.update(content_page_share_params)
      redirect_to @share, notice: 'Content page share was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /content_page_shares/1
  def destroy
    @share.destroy
    redirect_to(content_page_shares_url, notice: 'The share was successfully deleted.')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_content_page_share
    @share = ContentPageShare.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def content_page_share_params
    {
      content_page_type: params.require(:content_page_share).require(:content_page).split('-').first,
      content_page_id:   params.require(:content_page_share).require(:content_page).split('-').second,
      message:           params.require(:content_page_share).require(:message),
      user_id:           current_user.id,
      shared_at:         DateTime.current
    }
  end
end