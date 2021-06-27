class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder, only: [:show, :destroy, :update]

  def create
    folder = Folder.create(folder_params.merge({ user: current_user }))

    redirect_back(fallback_location: documents_path, notice: "Folder #{folder.title} created!")
  end

  def update
  end

  def destroy
  end

  def show
    @page_title = @folder.title || 'Untitled folder'

    @parent_folder = @folder.parent_folder
    @child_folders = Folder.where(parent_folder: @folder)

    # TODO: add other content types here too
    @content = Document.where(folder: @folder)
  end

  private

  def set_folder
    @folder = Folder.find_by(user: current_user, id: params.fetch(:id).to_i)
  end

  def folder_params
    params.require(:folder).permit(:title, :context, :parent_folder_id)
  end
end
