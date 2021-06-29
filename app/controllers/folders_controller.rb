class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: [:show, :destroy, :update]

  def create
    folder = Folder.create(folder_params.merge({ user: current_user }))

    redirect_back(fallback_location: documents_path, notice: "Folder #{folder.title} created!")
  end

  def update
    @folder.update(folder_params)

    redirect_back(fallback_location: folder_path(@folder), notice: "Folder #{@folder.title} updated!")
  end

  def destroy
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

    if params.key?(:slug)
      @filtered_page_tags = @page_tags.where(slug: params[:slug])
      @content.select! { |content| @filtered_page_tags.pluck(:page_id).include?(content.id) }
    end

    @page_tags = @page_tags.uniq(&:tag)
    @suggested_page_tags = (@page_tags.pluck(:tag) + PageTagService.suggested_tags_for(@content.klass.name)).uniq
  end

  private

  def set_folder
    @folder = Folder.find_by(user: current_user, id: params.fetch(:id).to_i)
  end

  def folder_params
    params.require(:folder).permit(:title, :context, :parent_folder_id)
  end
end
