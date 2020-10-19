class TimelinesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_timeline, only: [:show, :edit, :update, :destroy]

  before_action :set_navbar_color
  before_action :set_sidenav_expansion

  # GET /timelines
  def index
    @timelines = current_user.timelines
    @page_title = "My timelines"

    if @universe_scope
      @timelines = @timelines.where(universe: @universe_scope)
    end
  end

  def show
    @page_title = @timeline.name

    unless @timeline.privacy == 'public' || (user_signed_in? && current_user == @timeline.user)
      return redirect_back(fallback_location: root_path, notice: "You don't have permission to view that timeline!")
    end
  end

  # GET /timelines/new
  def new
    timeline = current_user.timelines.create(name: 'Untitled Timeline').reload
    redirect_to edit_timeline_path(timeline)
  end

  # GET /timelines/1/edit
  def edit
    @page_title = "Editing " + @timeline.name

    raise "No Access"   unless user_signed_in? && current_user == @timeline.user
  end

  # POST /timelines
  def create
    @page_title = "Create a timeline"

    # TODO this endpoint is probably just API-only, right?
    @timeline = Timeline.new(timeline_params)

    if current_user.on_premium_plan? && @timeline.save
      redirect_to @timeline, notice: 'Timeline was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /timelines/1
  def update
    return unless user_signed_in? && current_user == @timeline.user

    if @timeline.update(timeline_params)
      render status: 200, json: @timeline.reload
    else
      render status: 501, json: @timeline.errors
    end
  end

  # DELETE /timelines/1
  def destroy
    @timeline.destroy
    redirect_to timelines_url, notice: 'Timeline was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_timeline
    @timeline = Timeline.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def timeline_params
    params.require(:timeline).permit(:name, :subtitle, :description, :notes, :private_notes, :universe_id, :deleted_at, :archived_at, :privacy)
  end

  def set_navbar_color
    @navbar_color = Timeline.hex_color.presence || '#2196F3'
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end
end
