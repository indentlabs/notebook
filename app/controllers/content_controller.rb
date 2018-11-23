class ContentController < ApplicationController
  # todo before_action :load_content to set @content
  before_action :authenticate_user!, only: [:index, :new, :create, :edit, :update, :destroy, :deleted, :attributes]
  before_action :migrate_old_style_field_values, only: [:show, :edit]

  before_action :populate_linkable_content_for_each_content_type, only: [:new, :edit]

  def index
    @content_type_class = content_type_from_controller(self.class)
    pluralized_content_name = @content_type_class.name.downcase.pluralize

    # Create the default fields for this user if they don't have any already
    @content_type_class.attribute_categories(current_user)

    if @universe_scope.present? && @content_type_class != Universe
      @content = @universe_scope.send(pluralized_content_name)
    else
      @content = (
        current_user.send(pluralized_content_name) +
        current_user.send("contributable_#{pluralized_content_name}")
      )

      unless @content_type_class == Universe
        my_universe_ids = current_user.universes.pluck(:id)
        @content.concat(@content_type_class.where(universe_id: my_universe_ids))
      end
    end

    @content = @content.to_a.flatten.uniq.sort_by(&:name)

    respond_to do |format|
      format.html { render 'content/index' }
      format.json { render json: @content }
    end
  end

  def show
    content_type = content_type_from_controller(self.class)
    return redirect_to root_path unless valid_content_types.map(&:name).include?(content_type.name)
    @content = content_type.find(params[:id])
    @serialized_content = ContentSerializer.new(@content)
    # raise @serialized_content.data.inspect

    return redirect_to(root_path) if @content.user.nil? # deleted user's content
    return if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(@content.user.try(:email))

    if (current_user || User.new).can_read?(@content)
      if current_user
        if @content.updated_at > 30.minutes.ago
          Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed content', {
            'content_type': content_type.name,
            'content_owner': current_user.present? && current_user.id == @content.user_id,
            'logged_in_user': current_user.present?
          }) if Rails.env.production?
        else
          Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'viewed recently-modified content', {
            'content_type': content_type.name,
            'content_owner': current_user.present? && current_user.id == @content.user_id,
            'logged_in_user': current_user.present?
          }) if Rails.env.production?
        end
      end

      respond_to do |format|
        format.html { render 'content/show', locals: { content: @content } }
        format.json { render_json(@content) }
      end
    else
      return redirect_to root_path, notice: "You don't have permission to view that content."
    end
  end

  def new
    @content = content_type_from_controller(self.class)
               .new

    # todo this is a good spot to audit to disable and see if create permissions are ok also
    unless (current_user || User.new).can_create?(content_type_from_controller self.class)
      return redirect_back(fallback_location: root_path)
    end

    respond_to do |format|
      format.html { render 'content/new', locals: { content: @content } }
      format.json { render json: @content }
    end
  end

  def edit
    content_type_class = content_type_from_controller(self.class)
    @content = content_type_class.find_by(id: params[:id])

    if @content.nil?
      return redirect_to root_path,
             notice: "Either this #{content_type_class.name.downcase} doesn't exist, or you don't have access to view it."
    end

    unless @content.updatable_by? current_user
      return redirect_to @content, notice: t(:no_do_permission)
    end

    respond_to do |format|
      format.html { render 'content/edit', locals: { content: @content } }
      format.json { render json: @content }
    end
  end

  def create
    content_type = content_type_from_controller self.class
    initialize_object

    unless current_user.can_create?(content_type)
      # todo set flash[:notice] about premium
      return redirect_back fallback_location: root_path
    end

    #  Don't set name fields on content that doesn't have a name field
    #todo abstract this (and the one in update) to a function
    unless [AttributeCategory, AttributeField, Attribute].map(&:name).include?(@content.class.name)
      @content.name ||= @content.name_field_value || "Untitled"
    end

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'created content', {
      'content_type': content_type.name
    }) if Rails.env.production?

    @content.user = current_user if @content.user_id.nil?
    if @content.update_attributes(content_params)
      cache_params = {}
      cache_params[:name]     = @content.name_field_value unless [AttributeCategory, AttributeField].include?(@content.class)
      cache_params[:universe] = @content.universe_field_value if self.respond_to?(:universe_id)

      @content.update(cache_params) if cache_params.any?
      # Cache the name/universe also (todo stick this in the same save as above)

      if params.key? 'image_uploads'
        upload_files params['image_uploads'], content_type.name, @content.id
      end

      successful_response(content_creation_redirect_url, t(:create_success, model_name: humanized_model_name))
    else
      failed_response('new', :unprocessable_entity, "Unable to save page. Error code: " + @content.errors.map(&:messages).to_sentence)
    end
  end

  def update
    content_type = content_type_from_controller(self.class)
    @content = content_type.with_deleted.find(params[:id])

    unless @content.updatable_by?(current_user)
      # todo flash error instead? (shows up 2x currently)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: @content
    end

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'updated content', {
      'content_type': content_type.name
    }) if Rails.env.production?

    if params.key?('image_uploads')
      upload_files(params['image_uploads'], content_type.name, @content.id)
    end

    if @content.is_a?(Universe) && params.key?('contributors') && @content.user == current_user
      params[:contributors][:email].reject(&:blank?).each do |email|
        ContributorService.invite_contributor_to_universe(universe: @content, email: email.downcase)
      end
    end

    if @content.user == current_user
      # todo this needs some extra validation probably to ensure each attribute is one associated with this page
      update_success = @content.update_attributes(content_params)

      cache_params = {}
      cache_params[:name]     = @content.name_field_value unless [AttributeCategory, AttributeField, Attribute].include?(@content.class)
      cache_params[:universe] = @content.universe_field_value if self.respond_to?(:universe_id)

      @content.update(cache_params) if cache_params.any? && update_success
    else
      # Exclude fields only the real owner can edit
      #todo move field list somewhere when it grows
      update_success = @content.update_attributes(content_params.except(:universe_id))
    end

    if update_success
      successful_response(@content, t(:update_success, model_name: humanized_model_name))
    else
      failed_response('edit', :unprocessable_entity, "Unable to save page. Error code: " + @content.errors.map(&:messages).to_sentence)
    end
  end

  def upload_files image_uploads_list, content_type, content_id
    image_uploads_list.each do |image_data|
      image_size_kb = File.size(image_data.tempfile.path) / 1000.0

      if current_user.upload_bandwidth_kb < image_size_kb
        flash[:alert] = [
          "At least one of your images failed to upload because you do not have enough upload bandwidth.",
          "<a href='#{subscription_path}' class='btn white black-text center-align'>Get more</a>"
        ].map { |p| "<p>#{p}</p>" }.join
        next
      else
        current_user.update(upload_bandwidth_kb: current_user.upload_bandwidth_kb - image_size_kb)
      end

      related_image = ImageUpload.create(
        user: current_user,
        content_type: content_type,
        content_id: content_id,
        src: image_data,
        privacy: 'public'
      )

      Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'uploaded image', {
        'content_type': content_type,
        'image_size_kb': image_size_kb,
        'first five images': current_user.image_uploads.count <= 5
      }) if Rails.env.production?
    end
  end

  def destroy
    content_type = content_type_from_controller(self.class)
    @content = content_type.find_by(id: params[:id])

    unless current_user.can_delete? @content
      return redirect_to :back, notice: "You don't have permission to do that!"
    end

    Mixpanel::Tracker.new(Rails.application.config.mixpanel_token).track(current_user.id, 'deleted content', {
      'content_type': content_type.name
    }) if Rails.env.production?

    @content.destroy

    successful_response(content_deletion_redirect_url, t(:delete_success, model_name: humanized_model_name))
  end

  # List all recently-deleted content
  def deleted
    @content_pages = {}
    @activated_content_types.each do |content_type|
      @content_pages[content_type] = content_type.constantize.with_deleted.where('deleted_at > ?', 24.hours.ago).where(user_id: current_user.id)
    end
    @content_pages["Document"] = current_user.documents.with_deleted.where('deleted_at > ?', 24.hours.ago)
  end

  def attributes
    @content_type = params[:content_type]
    # todo make this a before_action load_content_type
    unless valid_content_types.map { |c| c.name.downcase }.include?(@content_type)
      raise "Invalid content type on attributes customization page: #{@content_type}"
    end
    @content_type_class = @content_type.titleize.constantize
  end

  private

  def render_json(content)
    render json: JSON.pretty_generate({
      name: content.try(:name),
      description: content.try(:description),
      universe: content.universe_id.nil? ? nil : {
        id: content.universe_id,
        name: content.universe.try(:name)
      },
      categories: Hash[content.class.attribute_categories(content.user).map { |category|
        [category.name, category.attribute_fields.map { |field|
          Hash[field.label, {
            id: field.name,
            value: field.attribute_values.find_by(
              entity_type: content.page_type,
              entity_id:   content.id
            ).try(:value) || ""
          }]
        }]
      }]
    })
  end

  def migrate_old_style_field_values
    content ||= content_type_from_controller(self.class).find_by(id: params[:id])
    TemporaryFieldMigrationService.migrate_fields_for_content(content, current_user) if content.present?
  end

  def populate_linkable_content_for_each_content_type
    linkable_classes = Rails.application.config.content_types[:all].map(&:name) & current_user.user_content_type_activators.pluck(:content_type)
    linkable_classes -= ["Universe"]

    @linkables_cache = {}
    linkable_classes.each do |class_name|
      # class_name = "Character"

      @linkables_cache[class_name] = current_user.send("linkable_#{class_name.downcase.pluralize}")
        .in_universe(@universe_scope)

      if @content.present? && @content.persisted?
        @linkables_cache[class_name] = @linkables_cache[class_name]
          .in_universe(@content.universe)
          .reject { |content| content.class.name == class_name && content.id == @content.id }
      end

      @linkables_cache[class_name] = @linkables_cache[class_name].sort_by(&:name)
        .map { |c| [c.name, c.id] }
        .compact
    end
  end

  def valid_content_types
    Rails.application.config.content_types[:all]
  end

  def initialize_object
    content_type = content_type_from_controller(self.class)
    @content = content_type.new(content_params).tap do |c|
      c.user_id = current_user.id
    end
  end

  def content_params
    content_class = content_type_from_controller(self.class)
      .name
      .downcase
      .to_sym

    params.require(content_class).permit(content_param_list + [:deleted_at])
  end

  def content_deletion_redirect_url
    send("#{@content.class.name.underscore.pluralize}_path")
  end

  def content_creation_redirect_url
    params[:redirect_override].presence || @content
  end

  def content_symbol
    content_type_from_controller(self.class).to_s.downcase.to_sym
  end

  def successful_response(url, notice)
    respond_to do |format|
      format.html {
        if params.key?(:override) && params[:override].key?(:redirect_path)
          redirect_to params[:override][:redirect_path], notice: notice
        else
          redirect_to url, notice: notice
        end
      }
      format.json { render json: @content || {}, status: :success }
    end
  end

  def failed_response(action, status, notice=nil)
    flash.now[:notice] = notice if notice
    respond_to do |format|
      format.html { render action: action, notice: notice }
      format.json { render json: @content.errors, status: status }
    end
  end

  def humanized_model_name
    content_type_from_controller(self.class).model_name.human
  end
end
