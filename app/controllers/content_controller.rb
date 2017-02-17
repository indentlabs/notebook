class ContentController < ApplicationController
  include HasOwnership

  before_action :authenticate_user!, only: [:index, :new, :create, :edit, :update, :destroy]

  def index
    @content = content_type_from_controller(self.class)
               .where(user_id: current_user.id)
               .order(:name)

    @content = @content.where(universe: @universe_scope) if @universe_scope.present? && @content.build.respond_to?(:universe)
    @content ||= []
    @questioned_content = @content.sample
    @question = @questioned_content.question unless @questioned_content.nil?

    respond_to do |format|
      format.html { render 'content/index' }
      format.json { render json: @content }
    end
  end

  def show
    content_type = content_type_from_controller(self.class)
    # TODO: Secure this with content class whitelist lel
    @content = content_type.find(params[:id])

    if (current_user || User.new).can_read? @content
      @question = @content.question if current_user.present? and current_user == @content.user

      respond_to do |format|
        format.html { render 'content/show', locals: { content: @content } }
        format.json { render json: @content }
      end
    else
      if current_user.present?
        return redirect_to :back
      else
        return redirect_to root_path
      end
    end
  end

  def new
    @content = content_type_from_controller(self.class)
               .new

    unless (current_user || User.new).can_create?(content_type_from_controller self.class)
      return redirect_to :back
    end

    respond_to do |format|
      format.html { render 'content/new', locals: { content: @content } }
      format.json { render json: @content }
    end
  end

  def edit
    @content = content_type_from_controller(self.class)
               .find(params[:id])

    unless @content.updatable_by? current_user
      return redirect_to :back
    end

    respond_to do |format|
      format.html { render 'content/edit', locals: { content: @content } }
      format.json { render json: @content }
    end
  end

  def create
    initialize_object

    unless current_user.can_create?(content_type_from_controller self.class)
      return redirect_to :back
    end

    if @content.save
      successful_response(content_creation_redirect_url, t(:create_success, model_name: humanized_model_name))
    else
      failed_response('new', :unprocessable_entity)
    end
  end

  def update
    content_type = content_type_from_controller(self.class)
    @content = content_type.find(params[:id])

    unless @content.updatable_by? current_user
      return redirect_to :back
    end

    if params.key? 'image_uploads'
      upload_files params['image_uploads'], content_type.name, @content.id
    end

    if @content.update_attributes(content_params)
      successful_response(@content, t(:update_success, model_name: humanized_model_name))
    else
      failed_response('edit', :unprocessable_entity)
    end
  end

  def upload_files image_uploads_hash, content_type, content_id
    image_uploads_hash.values.each do |image_data|
      related_image = ImageUpload.create(
        user: current_user,
        content_type: content_type,
        content_id: content_id,
        src: image_data,
        privacy: 'public'
      )
      raise [image_data, '|||', related_image].inspect
    end

    raise image_uploads_hash.values.inspect
  end

  def destroy
    content_type = content_type_from_controller(self.class)
    @content = content_type.find(params[:id])

    unless current_user.can_delete? @content
      return redirect_to :back
    end

    @content.destroy

    successful_response(content_deletion_redirect_url, t(:delete_success, model_name: humanized_model_name))
  end

  private

  def initialize_object
    content_type = content_type_from_controller(self.class)
    @content = content_type.new(content_params).tap do |c|
      c.user_id = current_user.id
    end
  end

  # Override in content classes
  def content_params
    params
  end

  def content_deletion_redirect_url
    send("#{@content.class.name.underscore.pluralize}_path")
  end

  def content_creation_redirect_url
    @content
  end

  def content_symbol
    content_type_from_controller(self.class).to_s.downcase.to_sym
  end

  def successful_response(url, notice)
    respond_to do |format|
      format.html { redirect_to url, notice: notice }
      format.json { render json: @content || {}, status: :success, notice: notice }
    end
  end

  def failed_response(action, status)
    respond_to do |format|
      format.html { render action: action }
      format.json { render json: @content.errors, status: status }
    end
  end

  def humanized_model_name
    content_type_from_controller(self.class).model_name.human
  end
end
