# frozen_string_literal: true

# TODO: we should probably spin off an Api::ContentController for #api_sort and anything else 
#       api-wise we need
class ContentController < ApplicationController
  before_action :authenticate_user!, except: [:show, :changelog, :api_sort, :gallery] \
    + Rails.application.config.content_types[:all_non_universe].map { |type| type.name.downcase.pluralize.to_sym }

  skip_before_action :cache_most_used_page_information, only: [
    :name_field_update, :text_field_update, :tags_field_update, :universe_field_update, :api_sort
  ]

  before_action :migrate_old_style_field_values, only: [:show, :edit]

  before_action :cache_linkable_content_for_each_content_type, only: [:new, :edit, :index]

  before_action :set_attributes_content_type, only: [:attributes]

  before_action :set_navbar_color, except: [:api_sort]
  before_action :set_navbar_actions, except: [:deleted, :api_sort]
  before_action :set_sidenav_expansion, except: [:api_sort]

  def index
    @content_type_class = content_type_from_controller(self.class)
    pluralized_content_name = @content_type_class.name.downcase.pluralize

    @page_title = "My #{pluralized_content_name}"

    # Create the default fields for this user if they don't have any already
    # TODO: uh, this probably doesn't belong here!
    @content_type_class.attribute_categories(current_user)

    # Linkables cache is already scoped per-universe, includes contributor pages
    @content = @linkables_raw.fetch(@content_type_class.name, [])

    @show_scope_notice = @universe_scope.present? && @content_type_class != Universe

    # Filters
    @page_tags = PageTag.where(
      page_type: @content_type_class.name,
      page_id:   @content.pluck(:id)
    ).order(:tag)
    if params.key?(:slug)
      @filtered_page_tags = @page_tags.where(slug: params[:slug])
      @content.select! { |content| @filtered_page_tags.pluck(:page_id).include?(content.id) }
    end
    @page_tags = @page_tags.uniq(&:tag)

    if params.key?(:favorite_only)
      @content.select!(&:favorite?)
    end

    @content = @content.sort_by {|x| [x.favorite? ? 0 : 1, x.name] }

    @questioned_content = @content.sample
    @attribute_field_to_question = SerendipitousService.question_for(@questioned_content)

    # Query for both regular and pinned images
    image_uploads = ImageUpload.where(
      content_type: @content_type_class.name,
      content_id:   @content.pluck(:id)
    )
    
    # Group by content but prioritize pinned images
    @random_image_including_private_pool_cache = {}
    image_uploads.group_by { |image| [image.content_type, image.content_id] }.each do |key, images|
      # Check for pinned images first that have a valid src
      pinned_image = images.find { |img| img.pinned }
      if pinned_image && pinned_image.src_file_name.present?
        @random_image_including_private_pool_cache[key] = [pinned_image]
      else
        # Use all valid images if no valid pinned image
        @random_image_including_private_pool_cache[key] = images.select { |img| img.src_file_name.present? }
      end
    end

    @saved_basil_commissions = BasilCommission.where(
      entity_type: @content_type_class.name,
      entity_id:   @content.pluck(:id)
    ).where.not(saved_at: nil)
    .group_by { |commission| [commission.entity_type, commission.entity_id] }

    # Uh, do we ever actually make JSON requests to logged-in user pages?
    respond_to do |format|
      format.html { render 'content/index' }
      format.json { render json: @content }
    end
  end

  def show    
    content_type = content_type_from_controller(self.class)
    return redirect_to(root_path, notice: "That page doesn't exist!", status: :not_found) unless valid_content_types.include?(content_type.name)

    @content = content_type.find_by(id: params[:id])
    return redirect_to(root_path, notice: "You don't have permission to view that content.", status: :not_found) if @content.nil?

    return redirect_to(root_path) if @content.user.nil? # deleted user's content    
    return if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(@content.user.try(:email))

    @serialized_content = ContentSerializer.new(@content)
    
    # For basil images, assume they're all public for now since there's no privacy column
    @basil_images = BasilCommission.where(entity: @content)
                                   .where.not(saved_at: nil)

    if (current_user || User.new).can_read?(@content)
      respond_to do |format|
        format.html { render 'content/show', locals: { content: @content } }
        format.json { render json: @serialized_content.data }
      end
    else
      return redirect_to root_path, notice: "You don't have permission to view that content."
    end
  end

  def new
    @content = content_type_from_controller(self.class)
      .new(user: current_user)
      .tap { |content| 
        content.name        = "New #{content.class.name}"
        content.universe_id = @universe_scope.try(:id) if content.respond_to?(:universe_id)
      }

    current_users_categories_and_fields = @content.class.attribute_categories(current_user)
    if current_users_categories_and_fields.empty?
      content_type_from_controller(self.class).create_default_attribute_categories(current_user)
      current_users_categories_and_fields = @content.class.attribute_categories(current_user)
    end

    if user_signed_in? && current_user.can_create?(@content.class) \
      || PermissionService.user_has_active_promotion_for_this_content_type(user: current_user, content_type: @content.class.name)

      # For users who are creating premium content in a collaborated universe without premium of their own
      # we want to default that content into one of their collaborated unvierses.
      if !current_user.on_premium_plan? && Rails.application.config.content_types[:premium].map(&:name).include?(@content.class.name)
        @content.universe_id = current_user.contributable_universes.first.try(:id)
      end

      if params.key?(:document_entity)
        entity = DocumentEntity.find_by(id: params.fetch(:document_entity).to_i)
        if entity.document_owner == current_user
          # Link the new page to the document entity
          @content.name = entity.text # cached name value
          @content.document_entity_id = entity.id
          
          # Since we're creating a new page here, we need to make sure we save it before requesting
          # a name field, since they're keyed off content IDs (and we don't have an ID before saving).
          @content.save!

          # Update the actual AttributeField's value for this page's name also
          @content.set_name_field_value(entity.text)
        end
      end

      @content.save!

      # If the user doesn't have this content type enabled, go ahead and automatically enable it for them
      current_user.user_content_type_activators.find_or_create_by(content_type: @content.class.name)

      return redirect_to edit_polymorphic_path(@content)
    else
      return redirect_to(subscription_path, notice: "#{@content.class.name.pluralize} require a Premium subscription to create.")
    end
  end

  def edit
    content_type_class = content_type_from_controller(self.class)
    @content = content_type_class.find_by(id: params[:id])
    if @content.nil?
      return redirect_to(root_path,
        notice: "Either this #{content_type_class.name.downcase} doesn't exist, or you don't have access to view it."
      )
    end

    @serialized_content = ContentSerializer.new(@content)
    @suggested_page_tags = (
      current_user.page_tags.where(page_type: content_type_class.name).pluck(:tag) +
        PageTagService.suggested_tags_for(content_type_class.name)
      ).uniq - @serialized_content.page_tags

    unless @content.updatable_by? current_user
      return redirect_to @content, notice: t(:no_do_permission)
    end

    @random_image_including_private_pool_cache = ImageUpload.where(
      user_id: current_user.id,
    ).group_by { |image| [image.content_type, image.content_id] }
    @basil_images       = BasilCommission.where(entity: @content)
                                         .where.not(saved_at: nil)

    respond_to do |format|
      format.html { render 'content/edit', locals: { content: @content } }
      format.json { render json: @content }
    end
  end

  def create
    content_type = content_type_from_controller(self.class)
    initialize_object

    unless current_user.can_create?(content_type) \
      || PermissionService.user_has_active_promotion_for_this_content_type(user: current_user, content_type: content_type.name)
      
      return redirect_back(fallback_location: root_path, notice: "Creating this type of page requires an active Premium subscription.")
    end

    # Default names to untitled until one has been set
    unless [AttributeCategory, AttributeField, Attribute].map(&:name).include?(@content.class.name)
      @content.name ||= "Untitled #{content_type.name.downcase}"
    end

    # Default owner to the current user
    @content.user_id ||= current_user.id

    if @content.save
      cache_params = {}
      cache_params[:name]     = @content.name_field_value unless [AttributeCategory, AttributeField].include?(@content.class)
      cache_params[:universe] = @content.universe_field_value if self.respond_to?(:universe_id)
      @content.update(cache_params) if cache_params.any?

      if params.key? 'image_uploads'
        upload_files params['image_uploads'], content_type.name, @content.id
      end

      update_page_tags if @content.respond_to?(:page_tags)
      
      if content_params.key?('document_entity_id')
        document_entity = DocumentEntity.find_by(id: content_params['document_entity_id'].to_i)
        if document_entity.document_owner == current_user
          document_entity.update(entity_id: @content.reload.id)
        end
      end

      # If the user doesn't have this content type enabled, go ahead and automatically enable it for them
      current_user.user_content_type_activators.find_or_create_by(content_type: content_type.name)

      successful_response(content_creation_redirect_url, t(:create_success, model_name: @content.try(:name).presence || humanized_model_name))
    else
      failed_response('new', :unprocessable_entity, "Unable to save page. Error code: " + @content.errors.to_json.to_s)
    end
  end

  def update
    # TODO: most things are stripped out now that we're using per-field updates, so we should
    # audit what's left of this function and what needs to stay
    content_type = content_type_from_controller(self.class)
    @content = content_type.with_deleted.find(params[:id])

    unless @content.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: @content
    end

    if params.key?('image_uploads')
      upload_files(params['image_uploads'], content_type.name, @content.id)
    end

    if @content.is_a?(Universe) && params.key?('contributors') && @content.user == current_user
      params[:contributors][:email].reject(&:blank?).each do |email|
        ContributorService.invite_contributor_to_universe(universe: @content, email: email.downcase)
      end
    end

    # update_page_tags if @content.respond_to?(:page_tags)

    if @content.user == current_user
      # todo this needs some extra validation probably to ensure each attribute is one associated with this page
      update_success = @content.reload.update(content_params)
    else
      # Exclude fields only the real owner can edit
      #todo move field list somewhere when it grows
      update_success = @content.update(content_params.except(:universe_id))
    end

    cache_params = {}
    # TODO strip relevant logic out to AttributeCategory#update and Attribute#update so we don't need this weird branch
    cache_params[:name]     = @content.name_field_value unless [AttributeCategory, Attribute].include?(@content.class)
    cache_params[:universe] = @content.universe_field_value if self.respond_to?(:universe_id)
    @content.update(cache_params) if cache_params.any? && update_success

    if update_success
      successful_response(@content, t(:update_success, model_name: @content.try(:name).presence || humanized_model_name))
    else
      failed_response('edit', :unprocessable_entity, "Unable to save page. Error code: " + @content.errors.to_json)
    end
  end

  def toggle_favorite
    content_type = content_type_from_controller(self.class)
    @content = content_type.with_deleted.find(params[:id])

    unless @content.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: @content
    end

    @content.update!(favorite: !@content.favorite)
  end

  def toggle_archive
    # todo Since this method is triggered via a GET in floating_action_buttons, a malicious user could technically archive
    # another user's content if they're able to send that user to a specifically-crafted URL or inject that URL somewhere on
    # a page (e.g. img src="/characters/1234/toggle_archive"). Since archiving is reversible this seems fine for release, but
    # is something that should be fixed asap before any abuse happens.

    content_type = content_type_from_controller(self.class)
    @content = content_type.with_deleted.find(params[:id])

    unless @content.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: @content
    end

    verb = nil
    success = if @content.archived?
      verb = "unarchived"
      @content.unarchive!
    else
      verb = "archived"
      @content.archive!
    end

    if success
      redirect_back(fallback_location: archive_path, notice: "This page has been #{verb}.")
    else
      redirect_back(fallback_location: root_path, notice: "Something went wrong while attempting to archive that page.")
    end
  end

  def changelog
    content_type = content_type_from_controller(self.class)
    return redirect_to root_path unless valid_content_types.include?(content_type.name)
    @content = content_type.find_by(id: params[:id])
    return redirect_to(root_path, notice: "You don't have permission to view that content.") if @content.nil?
    @serialized_content = ContentSerializer.new(@content)
    return redirect_to(root_path, notice: "You don't have permission to view that content.") unless @content.updatable_by?(current_user || User.new)

    if user_signed_in?
      @navbar_actions << {
        label: @serialized_content.name,
        href: main_app.polymorphic_path(@content)
      }

      @navbar_actions << {
        label: 'Changelog',
        href: send("changelog_#{content_type.name.downcase}_path", @content)
      }
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
    end
  end

  def destroy
    content_type = content_type_from_controller(self.class)
    @content = content_type.find_by(id: params[:id])

    unless current_user.can_delete?(@content)
      return redirect_to :back, notice: "You don't have permission to do that!"
    end

    cached_page_name = @content.try(:name)
    @content.destroy

    successful_response(content_deletion_redirect_url, t(:delete_success, model_name: cached_page_name.presence || humanized_model_name))
  end

  # List all recently-deleted content
  def deleted
    @maximum_recovery_time = current_user.on_premium_plan? ? 7.days : 48.hours

    @content_pages = {}
    @activated_content_types.each do |content_type|
      @content_pages[content_type] = content_type.constantize
        .with_deleted
        .where('deleted_at > ?', @maximum_recovery_time.ago)
        .where(user_id: current_user.id)
    end
    @content_pages["Document"] = current_user.documents
      .with_deleted
      .where('documents.deleted_at > ?', @maximum_recovery_time.ago)
      .includes(:user)

    # Override controller
    @sidenav_expansion = 'my account'
  end

  def attributes
    @attribute_categories = @content_type_class
      .attribute_categories(current_user, show_hidden: true)
      .shown_on_template_editor
      .order(:position)

    @dummy_model = @content_type_class.new
  end

  def gallery
    content_type = content_type_from_controller(self.class)
    @content = content_type.find_by(id: params[:id])
    return redirect_to(root_path, notice: "You don't have permission to view that content.") if @content.nil?
    
    return redirect_to(root_path) if @content.user.nil? # deleted user's content    
    return if ENV.key?('CONTENT_BLACKLIST') && ENV['CONTENT_BLACKLIST'].split(',').include?(@content.user.try(:email))
    
    if (current_user || User.new).can_read?(@content)
      # Serialize content for overview section
      @serialized_content = ContentSerializer.new(@content)

      # Get all images for this content with proper ordering
      # Only show private images to the owner or contributors
      is_owner_or_contributor = false
      # Check if the user is the owner or a contributor
      if current_user.present? && (@content.user == current_user || 
         (@content.respond_to?(:universe_id) && 
          @content.universe_id.present? && 
          current_user.try(:contributable_universe_ids).to_a.include?(@content.universe_id)))
        is_owner_or_contributor = true
        @images = ImageUpload.where(content_type: @content.class.name, content_id: @content.id).ordered
      else
        @images = ImageUpload.where(content_type: @content.class.name, content_id: @content.id, privacy: 'public').ordered
      end
      
      # Get additional context information
      if @content.is_a?(Universe)
        # Universe objects don't have a universe_id field
        @universe = nil
        @other_content = []
      else
        @universe = @content.universe_id.present? ? Universe.find_by(id: @content.universe_id) : nil
        @other_content = @content.universe_id.present? ? 
          content_type.where(universe_id: @content.universe_id).where.not(id: @content.id).limit(5) : []
      end
      
      # Include basil images too with proper ordering
      @basil_images = BasilCommission.where(entity: @content).where.not(saved_at: nil).ordered
      
      render 'content/gallery'
    else
      return redirect_to root_path, notice: "You don't have permission to view that content."
    end
  end

  def toggle_image_pin
    # Find the image based on type and ID
    if params[:image_type] == 'image_upload'
      @image = ImageUpload.find_by(id: params[:image_id])
    elsif params[:image_type] == 'basil_commission'
      @image = BasilCommission.find_by(id: params[:image_id])
    else
      return render json: { error: 'Invalid image type' }, status: 400
    end
    
    # Ensure the image exists and the user has permission to modify it
    if @image.nil?
      return render json: { error: 'Image not found' }, status: 404
    end
    
    # Check permissions
    content = params[:image_type] == 'image_upload' ? 
      @image.content : 
      @image.entity
      
    # Need to check if user owns or contributes to the content directly
    unless content.user_id == current_user.id || 
           (content.respond_to?(:universe_id) && 
            content.universe_id.present? && 
            current_user.contributable_universe_ids.include?(content.universe_id))
      return render json: { error: 'Unauthorized' }, status: 403
    end
    
    # Are we pinning or unpinning?
    new_pin_status = !@image.pinned
    
    # If we're pinning this image (not just unpinning), we need to unpin any other images
    if new_pin_status
      # First, unpin any other ImageUploads for this content
      if content.respond_to?(:image_uploads)
        content.image_uploads.where(pinned: true).where.not(id: params[:image_type] == 'image_upload' ? params[:image_id] : nil).update_all(pinned: false)
      end
      
      # Then, unpin any BasilCommissions for this content
      if content.respond_to?(:basil_commissions)
        content.basil_commissions.where(pinned: true).where.not(id: params[:image_type] == 'basil_commission' ? params[:image_id] : nil).update_all(pinned: false)
      end
    end
    
    # Now toggle this image's pin status - force with update_column to avoid callbacks
    @image.update_column(:pinned, new_pin_status)
    # Force reload to ensure we have latest pin status
    @image.reload
    
    # Clear any cached images to ensure pinned images are shown
    content.instance_variable_set(:@random_image_including_private_cache, nil)
    
    # Return the updated status
    render json: { 
      id: @image.id, 
      type: params[:image_type], 
      pinned: @image.pinned 
    }
  end

  def api_sort
    sort_params = params.permit(:content_id, :intended_position, :sortable_class)
    sortable_class = sort_params[:sortable_class].constantize # todo audit
    return unless sortable_class

    content = sortable_class.find_by(id: sort_params[:content_id].to_i)
    return unless content.present?
    return unless content.user_id == current_user.id
    return unless content.respond_to?(:position)

    # Ugh not another one of these backfills
    # todo remove this necessity
    if content.position.nil?
      if content.is_a?(AttributeCategory)
        content.backfill_categories_ordering!
      elsif content.is_a?(AttributeField)
        content.attribute_category.backfill_fields_ordering!
      else
        raise "Attempting to backfill ordering for a new class: #{content.class.name}"
      end
    end

    content.reload
    if content.insert_at(1 + sort_params[:intended_position].to_i)
      render json: 200
    else
      render json: 500
    end
  end

  # Content update for link-type fields
  def link_field_update
    @attribute_field = AttributeField.find_by(id: params[:field_id].to_i)
    attribute_value = @attribute_field.attribute_values.order('created_at desc').find_or_initialize_by(entity_params)
    attribute_value.user_id ||= current_user.id

    if params.key?(:attribute_field)
      attribute_value.value = params.require(:attribute_field).fetch('linked_pages', [])
    else
      attribute_value.value = []
    end
    attribute_value.save!

    # Make sure we create references from the entity to the linked pages
    set_entity
    referencing_page = @entity

    # TODO: move this into a link mention update job
    valid_reference_ids = []
    referenced_page_codes = JSON.parse(attribute_value.value)
    referenced_page_codes.each do |page_code|
      page_type, page_id = page_code.split('-')

      reference = referencing_page.outgoing_page_references.find_or_initialize_by(
        referenced_page_type:  page_type,
        referenced_page_id:    page_id,
        attribute_field_id:    @attribute_field.id,
        reference_type:        'linked'
      )
      reference.cached_relation_title = @attribute_field.label
      reference.save!

      valid_reference_ids << reference.reload.id
    end

    # Delete all other references still attached to this field, but not present in this request
    referencing_page.outgoing_page_references
      .where(attribute_field_id: @attribute_field.id)
      .where.not(id: valid_reference_ids)
      .destroy_all
  end

  # Content update for name fields
  def name_field_update
    @attribute_field = AttributeField.find_by(id: params[:field_id].to_i)
    attribute_value = @attribute_field.attribute_values.order('created_at desc').find_or_initialize_by(entity_params)
    attribute_value.value = field_params.fetch('value', '')
    attribute_value.user_id ||= current_user.id
    attribute_value.save!

    # We also need to update the cached `name` field on the content page itself
    entity_type = entity_params.fetch(:entity_type)
    raise "Invalid entity type: #{entity_params.fetch(:entity_type)}" unless valid_content_types.include?(entity_params.fetch('entity_type'))
    entity = entity_type.constantize.find_by(id: entity_params.fetch(:entity_id).to_i)
    entity.update(name: field_params.fetch('value', ''))

    render json: attribute_value.to_json, status: 200
  end

  # Content update for text_area fields
  def text_field_update
    text = field_params.fetch('value', '')
    @attribute_field = AttributeField.find_by(id: params[:field_id].to_i)
    attribute_value = @attribute_field.attribute_values.order('created_at desc').find_or_initialize_by(entity_params)
    attribute_value.user_id ||= current_user.id
    attribute_value.value = text
    attribute_value.save!

    UpdateTextAttributeReferencesJob.perform_later(attribute_value.id)

    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: "#{@attribute_field.label} updated!") }
      format.json { render json: attribute_value.to_json, status: 200 }
    end
  end

  def tags_field_update
    return unless valid_content_types.include?(entity_params.fetch('entity_type'))

    @attribute_field = AttributeField.find_by(id: params[:field_id].to_i)
    attribute_value = @attribute_field.attribute_values.order('created_at desc').find_or_initialize_by(entity_params)
    attribute_value.user_id ||= current_user.id
    attribute_value.value = field_params.fetch('value', '')
    attribute_value.save!

    # Create the actual page_tag models too
    set_entity
    @content = @entity
    update_page_tags

    render json: attribute_value.to_json, status: 200
  end

  def universe_field_update
    return unless valid_content_types.include?(entity_params.fetch('entity_type'))

    @attribute_field = AttributeField.find_by(id: params[:field_id].to_i)
    attribute_value = @attribute_field.attribute_values.order('created_at desc').find_or_initialize_by(entity_params)
    attribute_value.user_id ||= current_user.id

    new_universe_id = field_params.fetch('value', nil).to_i
    new_universe_id = nil if new_universe_id == 0
    attribute_value.value = new_universe_id
    attribute_value.save!

    @content = entity_params.fetch('entity_type').constantize.find_by(
      id:   entity_params.fetch('entity_id'), 
      user: current_user
    )
    @content.update!(universe_id: attribute_value.value)

    render json: attribute_value.to_json, status: 200
  end

  private

  def update_page_tags
    tag_list = field_params.fetch('value', '').split(PageTag::SUBMISSION_DELIMITER)
    current_tags = @content.page_tags.pluck(:tag)

    tags_to_add    = tag_list - current_tags
    tags_to_remove = current_tags - tag_list

    tags_to_add.each do |tag|
      # TODO: create changelog event for AddedTag
      @content.page_tags.find_or_create_by(
        tag:  tag,
        slug: PageTagService.slug_for(tag),
        user: @content.user
      )
    end

    tags_to_remove.each do |tag|
      # TODO: create changelog event for RemovedTag or use destroy_all
      @content.page_tags.find_by(tag: tag).destroy
    end
  end

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

  # todo just do the migration for everyone so we can finally get rid of this
  def migrate_old_style_field_values
    content ||= content_type_from_controller(self.class).find_by(id: params[:id])
    TemporaryFieldMigrationService.migrate_fields_for_content(content, current_user) if content.present?
  end

  def valid_content_types
    Rails.application.config.content_type_names[:all]
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

    params.require(content_class).except(:page_tags, :_destroy).permit(content_param_list + [:deleted_at, :document_entity_id])
  end

  def page_tag_params
    content_class = content_type_from_controller(self.class)
      .name
      .downcase
      .to_sym

    params.require(content_class).permit(:page_tags)
  end

  def entity_params
    params.require(:entity).permit(:entity_id, :entity_type)
  end

  def field_params
    params.require(:field).permit(:name, :value)
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
      format.json { render json: @content || {}, status: :ok }
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

  def set_attributes_content_type
    @content_type = params[:content_type]
    # todo make this a before_action load_content_type
    unless valid_content_types.map(&:downcase).include?(@content_type)
      raise "Invalid content type on attributes customization page: #{@content_type}"
    end
    @content_type_class = @content_type.titleize.constantize
  end

  def set_navbar_color
    content_type = @content_type_class || content_type_from_controller(self.class)
    @navbar_color = content_type.try(:hex_color) || '#2196F3'
  end

  def set_entity
    entity_page_type = entity_params.fetch(:entity_type)
    entity_page_id   = entity_params.fetch(:entity_id)
    
    return unless valid_content_types.include?(entity_page_type)
    @entity = entity_page_type.constantize.find_by(id: entity_page_id)    
  end

  # For index, new, edit
  # def set_general_navbar_actions
  #   content_type = @content_type_class || content_type_from_controller(self.class)
  #   return if [AttributeCategory, AttributeField, Attribute].include?(content_type)
    
  #   @navbar_actions = []

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
  #   } if user_signed_in? && current_user.can_create?(content_type) \
  #   || PermissionService.user_has_active_promotion_for_this_content_type(user: current_user, content_type: content_type.name)

  #   discussions_link = ForumsLinkbuilderService.worldbuilding_url(content_type)
  #   if discussions_link.present?
  #     @navbar_actions << {
  #       label: 'Discussions',
  #       href: discussions_link
  #     }
  #   end

  #   # @navbar_actions << {
  #   #   label: 'Customize template',
  #   #   class: 'right',
  #   #   href: main_app.attribute_customization_path(content_type.name.downcase)
  #   # }
  # end

  # For showing a specific piece of content
  def set_navbar_actions
    content_type = @content_type_class || content_type_from_controller(self.class)
    @navbar_actions = []

    return if [AttributeCategory, AttributeField].include?(content_type)
    
    # Set up navbar actions for gallery specifically
    if action_name == 'gallery' && @content.present?
      # Add a link to view the content page
      @navbar_actions << {
        label: @content.name,
        href: polymorphic_path(@content)
      }
      
      # Add a gallery title indicator
      @navbar_actions << {
        label: 'Gallery',
        href: send("gallery_#{@content.class.name.downcase}_path", @content)
      }
    end
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'worldbuilding'
  end
end
