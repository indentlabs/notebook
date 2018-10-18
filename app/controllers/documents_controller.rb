class DocumentsController < ApplicationController
  def index
    @documents = current_user.documents.order('title asc')
  end

  def edit
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
  end

  def update
    document = Document.find_or_initialize_by(id: params[:id], user: current_user)

    unless document.user == current_user
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    document.update(document_params)
    redirect_to(documents_path, notice: "Your document has been saved!")
  end

  def destroy
    document = Document.find_by(id: params[:id])

    if current_user.can_delete?(document)
      document.destroy
      redirect_back(fallback_location: documents_path, notice: "The document was successfully deleted.")
    else
      redirect_back(fallback_location: root_path, notice: "You don't have permission to do that!")
    end
  end

  def document_params
    params.require(:document).permit(:title, :body)
  end
end
