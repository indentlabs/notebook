class DocumentsController < ApplicationController
  def update
    document = Document.find(params[:id])

    unless document.user == current_user
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    document.update(document_params)
    redirect_to notes_path, notice: "Your scratchpad has been saved!"
  end

  def document_params
    params.require(:document).permit(:body)
  end
end
