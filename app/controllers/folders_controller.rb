class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder,              only: [:show, :destroy, :update]
  before_action :verify_folder_ownership, only: [:show, :destroy, :update]
  before_action :set_sidenav_expansion,   only: [:show]

  def create
    folder = Folder.create(folder_params.merge({ user: current_user }))
    redirect_back(fallback_location: documents_path, notice: "Folder #{folder.title} created!")
  end

  def update
    @folder.update(folder_params)

    redirect_back(fallback_location: folder_path(@folder), notice: "Folder #{@folder.title} updated!")
  end

  def destroy
    Document.where(folder_id: @folder.id).update_all(folder_id: nil)

    @folder.destroy!
    redirect_to(documents_path, notice: "Folder #{@folder.title} deleted!")
  end

  def show
    @page_title = @folder.title || 'Untitled folder'

    @parent_folder = @folder.parent_folder
    @child_folders = Folder.where(parent_folder: @folder)

    # TODO: add other content types here too
    @content = Document.where(folder: @folder)

    if @universe_scope
      @content = @content.where(universe: @universe_scope)
    end

    @page_tags = PageTag.where(
      page_type: Document.name,
      page_id:   @content.pluck(:id)
    ).order(:tag)

    if params.key?(:tag)
      @filtered_page_tags = @page_tags.where(slug: params[:tag])

      @content = @content.to_a.select { |content| @filtered_page_tags.pluck(:page_id).include?(content.id) }
      # TODO: the above could probably be replaced with something like the below, but not sure on nesting syntax
      # @content = @content.where(page_tags: { slug: @filtered_page_tags.pluck(:slug) })
    end

    @page_tags = @page_tags.uniq(&:tag)
    @suggested_page_tags = (@page_tags.pluck(:slug) + PageTagService.suggested_tags_for('Document')).uniq
  end

  private

  def set_folder
    @folder = Folder.find_by(user: current_user, id: params.fetch(:id).to_i)

    unless @folder
      raise "No folder found with ID #{params.fetch(:id).to_i}"
    end
  end

  def verify_folder_ownership
    unless user_signed_in? && current_user == @folder.user
      raise "Trying to access someone else's folder: #{current_user.id} tried to access #{@folder.user_id}'s folder #{@folder.id}"
    end
  end

  def folder_params
    params.require(:folder).permit(:title, :context, :parent_folder_id)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end
end
