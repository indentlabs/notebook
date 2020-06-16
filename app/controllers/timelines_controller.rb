class TimelinesController < ApplicationController
  before_action :set_timeline, only: [:show, :edit, :update, :destroy]

  before_action :set_navbar_color
  before_action :set_navbar_actions
  before_action :set_sidenav_expansion

  # GET /timelines
  def index
    @timelines = current_user.timelines
  end

  # GET /timelines/1
  def show
  end

  # GET /timelines/new
  def new
    timeline = current_user.timelines.create.reload
    redirect_to edit_timeline_path(timeline)
  end

  # GET /timelines/1/edit
  def edit

  end

  # POST /timelines
  def create
    @timeline = Timeline.new(timeline_params)

    if @timeline.save
      redirect_to @timeline, notice: 'Timeline was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /timelines/1
  def update
    if @timeline.update(timeline_params)
      redirect_to @timeline, notice: 'Timeline was successfully updated.'
    else
      render :edit
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
    params.require(:timeline).permit(:name, :description, :universe_id, :deleted_at, :archived_at, :privacy)
    params.fetch(:timeline, {})
  end

  def set_navbar_color
    @navbar_color = Timeline.hex_color.presence || '#2196F3'
  end

  def set_navbar_actions
    # content_type = @content_type_class || content_type_from_controller(self.class)
    # @navbar_actions = []

    # return if [AttributeCategory, AttributeField].include?(content_type)

    # if user_signed_in?
    #   if @current_user_content
    #     @navbar_actions << {
    #       label: "Your #{view_context.pluralize @current_user_content.fetch(content_type.name, []).count, content_type.name.downcase}",
    #       href: main_app.polymorphic_path(content_type)
    #     }
    #   end

    #   @navbar_actions << {
    #     label: "New #{content_type.name.downcase}",
    #     href: main_app.new_polymorphic_path(content_type),
    #     class: 'right'
    #   }
    # end

    # discussions_link = ForumsLinkbuilderService.worldbuilding_url(content_type)
    # if discussions_link.present?
    #   @navbar_actions << {
    #     label: 'Discussions',
    #     href: discussions_link
    #   }
    # end
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end
end
