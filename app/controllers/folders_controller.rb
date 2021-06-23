class FoldersController < ApplicationController
  before_action :authenticate_user!

  def create
    folder = Folder.create(folder_params.merge({ user: current_user }))

    redirect_back(fallback_location: documents_path, notice: "Folder #{folder.title} created!")
  end

  def update
  end

  def destroy
  end

  private

  def folder_params
    params.require(:folder).permit(:title, :context, :parent_folder_id)
  end
end
