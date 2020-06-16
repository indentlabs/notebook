class TimelineEventsController < ApplicationController
  before_action :set_timeline_event, only: [:show, :edit, :update, :destroy]

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
    @timeline_event = TimelineEvent.new(timeline_event_params)

    if @timeline_event.save
      redirect_to @timeline_event, notice: 'Timeline event was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /timeline_events/1
  def update
    if @timeline_event.update(timeline_event_params)
      redirect_to @timeline_event, notice: 'Timeline event was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /timeline_events/1
  def destroy
    @timeline_event.destroy
    redirect_to timeline_events_url, notice: 'Timeline event was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_timeline_event
    @timeline_event = TimelineEvent.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def timeline_event_params
    params.require(:timeline_event).permit(:time_label, :title, :description, :notes, :timeline_id)
  end
end
