class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents.order('title asc')
  end

  def show
    document = Document.find_by(id: params[:id])
    redirect_to edit_document_path(document)
  end

  def edit
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
  end

  def create
    created_document = current_user.documents.create(document_params)
    redirect_to edit_document_path(created_document), notice: "Your document has been saved!"
  end

  def update
    document = Document.with_deleted.find_or_initialize_by(id: params[:id], user: current_user)

    unless document.user == current_user
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    document.update(document_params)
    redirect_to(edit_document_path(document), notice: "Your document has been saved!")
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

  private

  def document_params
    params.require(:document).permit(:title, :body, :deleted_at)
  end
end
