class DocumentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @documents = current_user.documents.order('updated_at desc')
  end

  def show
    document = Document.find_by(id: params[:id], user_id: current_user.id)
    redirect_to edit_document_path(document)
  end

  def edit
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
    @document ||= current_user.documents.create

    # This eases documents from the old editor into the new one, replacing \n with <br>s
    # Todo this line can be removed after running a migration that updates all existing documents, since you can no longer create a document with raw newlines
    @document.update(body: @document.body.gsub("\n", "<br />")) if @document.body.present? && @document.body.include?("\n")

    redirect_to root_path unless @document.updatable_by?(current_user)
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

    if document.updatable_by?(current_user) && document.update(document_params)
      head 200, content_type: "text/html"
    else
      head 501, content_type: "text/html"
    end
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
