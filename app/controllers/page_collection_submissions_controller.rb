class PageCollectionSubmissionsController < ApplicationController
  before_action :set_page_collection_submission, only: [:show, :edit, :update, :destroy]

  # GET /page_collection_submissions
  def index
    @page_collection_submissions = PageCollectionSubmission.all
  end

  # GET /page_collection_submissions/1
  def show
  end

  # GET /page_collection_submissions/new
  def new
    @page_collection_submission = PageCollectionSubmission.new
  end

  # GET /page_collection_submissions/1/edit
  def edit
  end

  # POST /page_collection_submissions
  def create
    @page_collection_submission = PageCollectionSubmission.new(page_collection_submission_params)

    if @page_collection_submission.save
      redirect_to @page_collection_submission, notice: 'Page collection submission was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /page_collection_submissions/1
  def update
    if @page_collection_submission.update(page_collection_submission_params)
      redirect_to @page_collection_submission, notice: 'Page collection submission was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /page_collection_submissions/1
  def destroy
    @page_collection_submission.destroy
    redirect_to page_collection_submissions_url, notice: 'Page collection submission was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_collection_submission
      @page_collection_submission = PageCollectionSubmission.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def page_collection_submission_params
      params.fetch(:page_collection_submission, {})
    end
end
