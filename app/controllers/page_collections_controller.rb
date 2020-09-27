class PageCollectionsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  before_action :set_sidenav_expansion
  before_action :set_page_collection, only: [:show, :edit, :update, :destroy, :follow, :unfollow, :report]
  before_action :set_navbar_color

  # GET /page_collections
  def index
    @my_collections = current_user.page_collections

    followed_user_ids = UserFollowing.where(user_id: current_user.id).pluck(:followed_user_id)
    @network_collections = PageCollection.where(user_id: followed_user_ids, privacy: 'public')

    @random_collections = PageCollection.where(privacy: 'public').sample(9)
  end

  # GET /page_collections/1
  def show
    unless (@page_collection.privacy == 'public' || (user_signed_in? && @page_collection.user == current_user))
      return redirect_to page_collections_path, notice: "That Collection is not public."
    end

    @pages = @page_collection.accepted_submissions
    sort_pages

    @submittable_content = if user_signed_in?
      @current_user_content.slice(*@page_collection.page_types)
    else
      []
    end
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
    @page_collection = PageCollection.new(page_collection_params.merge({user: current_user}))

    # Build page types from params checkbox list
    @page_collection.page_types = page_collection_page_types_param if params.require(:page_collection).key?(:page_types)

    if @page_collection.save
      # Add a stream event for every user following this user if the collection is public
      ContentPageShare.create(
        user_id:                     current_user.id,
        content_page_type:           PageCollection.name,
        content_page_id:             @page_collection.reload.id,
        shared_at:                   @page_collection.created_at,
        privacy:                     'public',
        message:                     "I created a new Collection!"
      )

      redirect_to @page_collection, notice: 'Your collection was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /page_collections/1
  def update
    if user_signed_in? && current_user == @page_collection.user    
      @page_collection.page_types = page_collection_page_types_param if params.require(:page_collection).key?(:page_types)
      if @page_collection.update(page_collection_params)
        redirect_to @page_collection, notice: 'Collection settings updated successfully.'
      else
        render :edit
      end
    else
      render :edit
    end
  end

  # DELETE /page_collections/1
  def destroy
    unless user_signed_in? && current_user == @page_collection.user
      raise "Permission denied"
      return
    end

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

  def by_user
    @page_collection = PageCollection.find(params[:page_collection_id])

    unless (@page_collection.privacy == 'public' || (user_signed_in? && @page_collection.user == current_user))
      return redirect_to page_collections_path, notice: "That Collection is not public."
    end

    @pages = @page_collection.accepted_submissions.where(user_id: params[:user_id])
    sort_pages

    @submittable_content = if user_signed_in?
      @current_user_content.slice(*@page_collection.page_types)
    else
      []
    end

    @show_contributor_highlight = true
    @highlighted_contributor = User.find_by(id: params[:user_id].to_i)
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_page_collection
    @page_collection = PageCollection.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def page_collection_params
    params.require(:page_collection).permit(:title, :subtitle, :description, :color, :privacy, :allow_submissions, :auto_accept, :header_image)
  end

  def page_collection_page_types_param
    list = params.require(:page_collection).fetch('page_types', {}).select { |t, enabled| enabled == "1" }.keys

    # Make sure we AND with a whitelist of approved page types
    list & Rails.application.config.content_types[:all].map(&:name)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'community'
  end
  
  def set_navbar_color
    @navbar_color = PageCollection.hex_color
  end

  def sort_pages
    case params.permit(:sort).fetch('sort', nil)
    when 'alphabetical'
      @pages = @pages.reorder('cached_content_name ASC')
    when 'chronological'
      @pages = @pages.reorder('accepted_at ASC')
    when 'recent'
      @pages = @pages.reorder('accepted_at DESC')
    when nil
    end
  end
end
