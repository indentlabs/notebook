class PageCollectionSubmissionsController < ApplicationController
  before_action :set_page_collection, only: [:index]
  before_action :set_page_collection_submission, only: [:destroy, :approve, :pass]

  before_action :require_collection_ownership, only: [:index]

  before_action :authenticate_user!, only: [:create]
  before_action :require_open_collection, only: [:create]

  # GET /page_collection_submissions
  def index
    @page_collection_submissions = @page_collection.page_collection_submissions.where(accepted_at: nil)
  end

  # POST /page_collection_submissions
  def create
    begin
      @page_collection_submission = PageCollectionSubmission.new(page_collection_submission_params)

      if @page_collection_submission.save
        redirect_to @page_collection_submission.page_collection, notice: 'Page submitted!'
      else
        page_collection = PageCollection.find(params[:page_collection_submission][:page_collection_id])
        redirect_to page_collection, alert: 'There was a problem submitting your page. Please try again.'
      end
    rescue ActionController::ParameterMissing => e
      page_collection = PageCollection.find(params[:page_collection_submission][:page_collection_id]) rescue nil
      if page_collection
        redirect_to page_collection, alert: 'Please select content to submit.'
      else
        redirect_to page_collections_path, alert: 'Invalid submission.'
      end
    rescue => e
      Rails.logger.error "PageCollectionSubmission creation failed: #{e.message}"
      page_collection = PageCollection.find(params[:page_collection_submission][:page_collection_id]) rescue nil
      if page_collection
        redirect_to page_collection, alert: 'There was a problem submitting your page. Please try again.'
      else
        redirect_to page_collections_path, alert: 'Invalid submission.'
      end
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
      passthrough_link: Rails.application.routes.url_helpers.page_collection_path(@page_collection_submission.page_collection),
      reference_code:   'approved-in-collection'
    )

    redirect_to(page_collection_pending_submissions_path(@page_collection_submission.page_collection), notice: "Submission approved!")
  end

  def pass
    return raise "Not allowed: pass" unless user_signed_in? && current_user == @page_collection_submission.page_collection.user
    @page_collection_submission.destroy
    redirect_to(page_collection_pending_submissions_path(@page_collection_submission.page_collection), notice: "Submission passed on!")
  end

  private

  # Owners can add anything to their own collection. Everyone else needs a public
  # collection that's taking submissions of that page type.
  def require_open_collection
    submission = params.fetch(:page_collection_submission, {})
    collection = PageCollection.find_by(id: submission[:page_collection_id])
    return redirect_to(page_collections_path, alert: 'Invalid submission.') if collection.nil?
    return if collection.user_id == current_user.id

    page_type = submission[:content].to_s.split('-').first
    return if collection.allow_submissions? && collection.privacy == 'public' && collection.page_types.include?(page_type)

    redirect_to collection, alert: "This collection isn't taking that submission."
  end

  def require_collection_ownership
    raise "Forbidden!" unless user_signed_in? && @page_collection.user_id == current_user.id
  end

  def set_page_collection
    @page_collection = PageCollection.find(params[:page_collection_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_page_collection_submission
    @page_collection_submission = PageCollectionSubmission.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def page_collection_submission_params
    content_param = params.require(:page_collection_submission).fetch(:content, '')
    
    if content_param.blank?
      raise ActionController::ParameterMissing.new(:content)
    end
    
    content_parts = content_param.split('-')
    if content_parts.length != 2
      raise ActionController::BadRequest.new("Invalid content format")
    end
    
    {
      content_type: content_parts.first,
      content_id:   content_parts.second,
      explanation:  params.require(:page_collection_submission).fetch(:explanation, ''),
      user_id:      current_user.id,
      submitted_at: DateTime.current,
      page_collection_id: params.require(:page_collection_submission).require(:page_collection_id)
    }
  end
end
