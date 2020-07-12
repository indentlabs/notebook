class PageCollectionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_sidenav_expansion
  before_action :set_page_collection, only: [:show, :edit, :update, :destroy, :follow, :unfollow, :report]

  # GET /page_collections
  def index
    @page_collections = PageCollection.all
  end

  # GET /page_collections/1
  def show
    @pages = @page_collection.accepted_submissions
    sort_pages
  end

  # GET /page_collections/new
  def new
    @page_collection = PageCollection.new
  end

  # GET /page_collections/1/edit
  def edit
  end

  # POST /page_collections
  def create
    @page_collection = PageCollection.new(page_collection_params)

    if @page_collection.save
      redirect_to @page_collection, notice: 'Page collection was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /page_collections/1
  def update
    if user_signed_in? && current_user == @page_collection.user && @page_collection.update(page_collection_params)
      redirect_to @page_collection, notice: 'Collection settings updated successfully.'
    else
      render :edit
    end
  end

  # DELETE /page_collections/1
  def destroy
    @page_collection.destroy
    redirect_to page_collections_url, notice: 'Page collection was successfully destroyed.'
  end

  def explore
    @collections = PageCollection.first(8)
  end

  Rails.application.config.content_types[:all].each do |content_type|
    define_method(content_type.name.downcase.pluralize.to_sym) do
      set_page_collection

      @pages = @page_collection.accepted_submissions.where(content_type: content_type.name)
      sort_pages

      render :show
    end
  end

  def follow
    @page_collection.page_collection_followings.find_or_create_by(user_id: current_user.id)
    redirect_to @page_collection, notice: 'You will now receive notifications about this Collection.'
  end

  def unfollow
    @page_collection.page_collection_followings.find_by(user_id: current_user.id).try(:destroy)
    redirect_to @page_collection, notice: 'You will no longer receive notifications about this Collection.'
  end

  def report
    @page_collection.page_collection_reports.create(user_id: current_user.id)
    redirect_to root_path, notice: "That Collection has been reported to site administration. Thank you!"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_page_collection
    @page_collection = PageCollection.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def page_collection_params
    params.require(:page_collection).permit(:title, :subtitle, :description, :color, :cover_image, :auto_accept)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'community'
  end

  def sort_pages
    case params.permit(:sort).fetch('sort', nil)
    when 'alphabetical'
      @pages = @pages.order('cached_content_name ASC')
    when 'chronological'
      @pages = @pages.order('accepted_at ASC')
    when 'recent'
      @pages = @pages.order('accepted_at DESC')
    when nil
    end
  end
end
