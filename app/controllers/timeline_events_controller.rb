class TimelineEventsController < ApplicationController
  before_action :set_timeline_event, only: [
    :show, :edit, :update, :destroy,
    :move_up, :move_to_top, :move_down, :move_to_bottom,
    :link_entity, :unlink_entity, :add_tag, :remove_tag
  ]

  # GET /timeline_events
  def index
    @timeline_events = TimelineEvent.all
  end

  # GET /timeline_events/1
  def show
  end

  # GET /timeline_events/new
  def new
    @timeline_event = TimelineEvent.new
  end

  # GET /timeline_events/1/edit
  def edit
  end

  # POST /timeline_events
  def create
    raise "No Access: (signed in: #{user_signed_in?})" unless user_signed_in? && current_user.timelines.pluck(:id).include?(timeline_event_params.fetch('timeline_id').to_i)

    @timeline_event = TimelineEvent.new(timeline_event_params)

    if @timeline_event.save
      @timeline_event.reload

      # Render the event card partial as HTML for client-side injection
      html = render_to_string(
        partial: 'timeline_events/event_card',
        locals: {
          event: @timeline_event,
          timeline: @timeline_event.timeline,
          index: @timeline_event.timeline.timeline_events.count - 1
        },
        formats: [:html]
      )

      render json: {
        status: 'success',
        id: @timeline_event.id,
        html: html
      }
    else
      raise "Failed to create TimelineEvent"
    end
  end

  # PATCH/PUT /timeline_events/1
  def update
    if @timeline_event.update(timeline_event_params)
      respond_to do |format|
        format.html { redirect_to @timeline_event, notice: 'Timeline event was successfully updated.' }
        format.json { render json: { status: 'success', message: 'Timeline event updated successfully' } }
        format.js   { render json: { status: 'success', message: 'Timeline event updated successfully' } }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { status: 'error', message: 'Failed to update timeline event', errors: @timeline_event.errors.full_messages }, status: :unprocessable_entity }
        format.js   { render json: { status: 'error', message: 'Failed to update timeline event', errors: @timeline_event.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timeline_events/1
  def destroy
    timeline = @timeline_event.timeline
    @timeline_event.destroy
    redirect_to edit_timeline_path(timeline), notice: 'Timeline event was successfully removed.'
  end

  def link_entity
    return render json: { error: 'Not authorized' }, status: :forbidden unless @timeline_event.can_be_modified_by?(current_user)
    
    entity = @timeline_event.timeline_event_entities.find_or_create_by(timeline_event_entity_params)
    
    if entity.persisted?
      # Reload the timeline event to get the latest linked content
      @timeline_event.reload
      
      render json: { 
        status: 'success', 
        message: 'Content linked successfully',
        html: render_to_string(
          partial: 'shared/timeline_event_linked_content', 
          locals: { timeline_event: @timeline_event }
        )
      }
    else
      render json: { 
        status: 'error', 
        message: 'Failed to link content',
        errors: entity.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def unlink_entity
    return render json: { error: 'Not authorized' }, status: :forbidden unless @timeline_event.can_be_modified_by?(current_user)
    
    entity = @timeline_event.timeline_event_entities.find_by(id: params[:entity_id].to_i)
    
    if entity&.destroy
      # Reload the timeline event to get the latest linked content
      @timeline_event.reload
      
      render json: { 
        status: 'success', 
        message: 'Content unlinked successfully',
        html: render_to_string(
          partial: 'shared/timeline_event_linked_content', 
          locals: { timeline_event: @timeline_event }
        )
      }
    else
      render json: { 
        status: 'error', 
        message: 'Failed to unlink content' 
      }, status: :unprocessable_entity
    end
  end

  # Move functions
  def move_up
    @timeline_event.move_higher if @timeline_event.can_be_modified_by?(current_user)
  end

  def move_down
    @timeline_event.move_lower if @timeline_event.can_be_modified_by?(current_user)
  end

  def move_to_top
    @timeline_event.move_to_top if @timeline_event.can_be_modified_by?(current_user)
  end

  def move_to_bottom
    @timeline_event.move_to_bottom if @timeline_event.can_be_modified_by?(current_user)
  end

  # Drag and drop sorting endpoint (internal API)
  def sort
    content_id = params[:content_id]
    intended_position = params[:intended_position].to_i
    
    timeline_event = TimelineEvent.find_by(id: content_id)
    
    unless timeline_event
      render json: { error: "Timeline event not found" }, status: :not_found
      return
    end
    
    unless timeline_event.can_be_modified_by?(current_user)
      render json: { error: "You don't have permission to reorder that timeline event" }, status: :forbidden
      return
    end
    
    # Use acts_as_list to move to the intended position
    timeline_event.insert_at(intended_position + 1) # acts_as_list is 1-indexed
    
    render json: { 
      success: true, 
      message: "New position saved", # "Timeline event moved to position #{intended_position + 1}"
      timeline_event: {
        id: timeline_event.id,
        position: timeline_event.position,
        title: timeline_event.title
      }
    }, status: :ok
  end

  def add_tag
    return render json: { error: 'Not authorized' }, status: :forbidden unless @timeline_event.can_be_modified_by?(current_user)
    
    tag_name = params[:tag_name]&.strip
    return render json: { error: 'Tag name is required' }, status: :bad_request if tag_name.blank?
    
    # Check if tag already exists for this event
    existing_tag = @timeline_event.page_tags.find_by(tag: tag_name)
    if existing_tag
      return render json: { 
        status: 'error', 
        message: 'Tag already exists for this event' 
      }, status: :unprocessable_entity
    end
    
    # Create the tag
    tag = @timeline_event.page_tags.create(
      tag: tag_name,
      slug: PageTagService.slug_for(tag_name),
      user: current_user
    )
    
    if tag.persisted?
      render json: { 
        status: 'success', 
        message: 'Tag added successfully',
        tag: {
          id: tag.id,
          name: tag.tag
        }
      }
    else
      render json: { 
        status: 'error', 
        message: 'Failed to add tag',
        errors: tag.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def remove_tag
    return render json: { error: 'Not authorized' }, status: :forbidden unless @timeline_event.can_be_modified_by?(current_user)
    
    tag_name = params[:tag_name]&.strip
    return render json: { error: 'Tag name is required' }, status: :bad_request if tag_name.blank?
    
    tag = @timeline_event.page_tags.find_by(tag: tag_name)
    
    if tag&.destroy
      render json: { 
        status: 'success', 
        message: 'Tag removed successfully' 
      }
    else
      render json: { 
        status: 'error', 
        message: 'Tag not found or failed to remove' 
      }, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_timeline_event
    @timeline_event = TimelineEvent.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def timeline_event_params
    params.require(:timeline_event).permit(:time_label, :title, :description, :notes, :timeline_id, 
                                          :event_type, :importance_level, :end_time_label, :status, :private_notes)
  end

  def timeline_event_entity_params
    params.permit(:entity_type, :entity_id)
  end
end
