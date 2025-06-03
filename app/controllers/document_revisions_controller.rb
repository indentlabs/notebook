class DocumentRevisionsController < ApplicationController
  before_action :set_document, only: [:index, :show, :destroy]
  before_action :set_document_revision, only: [:show, :edit, :update, :destroy]

  # GET /document_revisions
  def index
    @document_revisions = @document.document_revisions.order('created_at DESC').paginate(page: params[:page], per_page: 10)
  end

  # GET /document_revisions/1
  def show
  end

  # GET /document_revisions/new
  def new
    @document_revision = DocumentRevision.new
  end

  # GET /document_revisions/1/edit
  def edit
  end

  # POST /document_revisions
  def create
    @document_revision = DocumentRevision.new(document_revision_params)

    if @document_revision.save
      redirect_to @document_revision, notice: 'Document revision was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /document_revisions/1
  def update
    if @document_revision.update(document_revision_params)
      redirect_to @document_revision, notice: 'Document revision was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /document_revisions/1
  def destroy
    @document_revision.destroy
    redirect_to document_document_revisions_path(@document), notice: 'Document revision was successfully deleted.'
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_document_revision
    @document_revision = DocumentRevision.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def document_revision_params
    params.fetch(:document_revision, {})
  end
end
