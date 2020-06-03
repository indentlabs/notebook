class PageCollectionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  before_action :set_sidenav_expansion
  before_action :set_page_collection, only: [:show, :edit, :update, :destroy]

  # GET /page_collections
  def index
    @page_collections = PageCollection.all
  end

  # GET /page_collections/1
  def show
    @pages = @page_collection.accepted_submissions

    case params.permit(:sort).fetch('sort', nil)
    when 'alphabetical'
      @pages = @pages.order('cached_content_name ASC')
    when 'chronological'
      @pages = @pages.order('accepted_at DESC')
    when nil
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
end
