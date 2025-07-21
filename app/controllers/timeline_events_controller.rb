class TimelineEventsController < ApplicationController
  before_action :set_timeline_event, only: [
    :show, :edit, :update, :destroy,
    :move_up, :move_to_top, :move_down, :move_to_bottom,
    :link_entity, :unlink_entity
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
      render json: { status: 'success', id: @timeline_event.reload.id }
    else
      raise "Failed to create TimelineEvent"
    end
  end

  # PATCH/PUT /timeline_events/1
  def update
    if @timeline_event.update(timeline_event_params)
      redirect_to @timeline_event, notice: 'Timeline event was successfully updated.'
    else
      require 'pry'
      binding.pry
      render json: :failure
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
      render json: { 
        status: 'success', 
        message: 'Content linked successfully',
        entity_id: entity.id,
        entity_type: entity.entity_type
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
      render json: { 
        status: 'success', 
        message: 'Content unlinked successfully' 
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
