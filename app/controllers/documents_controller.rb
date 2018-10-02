class DocumentsController < ApplicationController
  def index
    @documents = current_user.documents
  end

  def edit
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
  end

  def update
    document = Document.find(params[:id])

    unless document.user == current_user
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    document.update(document_params)
    redirect_to documents_path, notice: "Your document has been saved!"
  end

  def document_params
    params.require(:document).permit(:body)
  end
end
