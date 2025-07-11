class PageCollectionEditorPicksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_collection
  before_action :require_collection_ownership

  layout 'tailwind'

  # GET /collections/:page_collection_id/editor_picks
  def index
    @current_picks = @page_collection.editor_picks_ordered.includes({content: [:universe, :user], user: []})
    @available_submissions = @page_collection.accepted_submissions
                                            .where(editor_pick_position: nil)
                                            .includes({content: [:universe, :user], user: []})
                                            .order('accepted_at DESC')
  end

  # POST /collections/:page_collection_id/editor_picks
  def create
    @submission = @page_collection.page_collection_submissions.find(params[:submission_id])
    
    # Find the next available position
    current_positions = @page_collection.editor_picks_ordered.pluck(:editor_pick_position)
    next_position = (1..6).find { |pos| !current_positions.include?(pos) }
    
    if next_position && @submission.update(editor_pick_position: next_position)
      render json: { 
        success: true, 
        message: "Added to Editor's Picks in position #{next_position}",
        position: next_position 
      }
    else
      render json: { 
        success: false, 
        message: "Unable to add to Editor's Picks. Maximum of 6 picks allowed." 
      }
    end
  end

  # PATCH /collections/:page_collection_id/editor_picks/:id
  def update
    @submission = @page_collection.page_collection_submissions.find(params[:id])
    new_position = params[:position].to_i
    
    if (1..6).include?(new_position)
      # Handle position swapping if needed
      existing_submission = @page_collection.page_collection_submissions
                                           .find_by(editor_pick_position: new_position)
      
      if existing_submission && existing_submission != @submission
        existing_submission.update(editor_pick_position: @submission.editor_pick_position)
      end
      
      @submission.update(editor_pick_position: new_position)
      render json: { success: true, message: "Position updated successfully" }
    else
      render json: { success: false, message: "Invalid position" }
    end
  end

  # DELETE /collections/:page_collection_id/editor_picks/:id
  def destroy
    @submission = @page_collection.page_collection_submissions.find(params[:id])
    
    if @submission.update(editor_pick_position: nil)
      render json: { success: true, message: "Removed from Editor's Picks" }
    else
      render json: { success: false, message: "Unable to remove from Editor's Picks" }
    end
  end

  private

  def set_page_collection
    @page_collection = PageCollection.find(params[:page_collection_id])
  end

  def require_collection_ownership
    unless @page_collection.user == current_user
      redirect_to @page_collection, alert: "You don't have permission to manage this collection's editor picks."
    end
  end
end