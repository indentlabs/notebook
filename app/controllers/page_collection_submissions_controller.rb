class PageCollectionSubmissionsController < ApplicationController
  before_action :set_page_collection, only: [:index]
  before_action :set_page_collection_submission, only: [:show, :edit, :update, :destroy, :approve, :pass]

  # GET /page_collection_submissions
  def index
    @page_collection_submissions = @page_collection.page_collection_submissions.where(accepted_at: nil)
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
      if @page_collection_submission.page_collection.try(:privacy) == 'public'
        @page_collection_submission.content.update(privacy: 'public')
      end

      redirect_to @page_collection_submission.page_collection, notice: 'Page submitted!'
    else
      raise "failed create"
      # render :new
    end
  end

  # PATCH/PUT /page_collection_submissions/1
  def update
    if @page_collection_submission.update(page_collection_submission_params)
      redirect_to @page_collection_submission, notice: 'Page collection submission was successfully updated.'
    else
      raise "failed edit"
      # render :edit
    end
  end

  # DELETE /page_collection_submissions/1
  def destroy
    unless user_signed_in? && current_user == @page_collection_submission.page_collection.user
      raise "Not allowed"
      return
    end

    page_collection = @page_collection_submission.page_collection
    @page_collection_submission.destroy
    redirect_to page_collection, notice: 'The page was successfully removed from this collection.'
  end

  def approve
    return raise "Not allowed: approve" unless user_signed_in? && current_user == @page_collection_submission.page_collection.user
    @page_collection_submission.accept!

    # Create a notification for the submitter to let them know it's been accepted
    @page_collection_submission.user.notifications.create(
      message_html:     "<div>Your <span class='#{@page_collection_submission.content.class.text_color}'>#{@page_collection_submission.content.name}</span> #{@page_collection_submission.content_type.downcase} submission to <span class='#{PageCollection.text_color}'>#{@page_collection_submission.page_collection.title}</span> was approved!</div>",
      icon:             PageCollection.icon,
      icon_color:       PageCollection.color,
      happened_at:      DateTime.current,
      passthrough_link: Rails.application.routes.url_helpers.page_collection_path(@page_collection_submission.page_collection)
    )

    redirect_to(page_collection_pending_submissions_path(@page_collection_submission.page_collection), notice: "Submission approved!")
  end

  def pass
    return raise "Not allowed: pass" unless user_signed_in? && current_user == @page_collection_submission.page_collection.user
    @page_collection_submission.destroy
    redirect_to(page_collection_pending_submissions_path(@page_collection_submission.page_collection), notice: "Submission passed on!")
  end

  private

  def set_page_collection
    @page_collection = PageCollection.find(params[:page_collection_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_page_collection_submission
    @page_collection_submission = PageCollectionSubmission.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def page_collection_submission_params
    {
      content_type: params.require(:page_collection_submission).require(:content).split('-').first,
      content_id:   params.require(:page_collection_submission).require(:content).split('-').second,
      explanation:  params.require(:page_collection_submission).fetch(:explanation, ''),
      user_id:      current_user.id,
      submitted_at: DateTime.current,
      page_collection_id: params.require(:page_collection_submission).require(:page_collection_id)
    }
  end
end
