class DocumentsController < ApplicationController
  layout :determine_layout

  before_action :authenticate_user!, except: [:show, :analysis]

  # todo Uh, this is a hack. The CSRF token on document editor model to add entities is being rejected... for whatever reason.
  skip_before_action :verify_authenticity_token, only: [:link_entity]

  before_action :set_document,          only:   [:show, :analysis, :plaintext, :printable, :queue_analysis, :edit, :destroy]
  before_action :set_sidenav_expansion, except: [:plaintext]
  before_action :set_navbar_color,      except: [:plaintext]
  before_action :set_navbar_actions,    except: [:edit, :plaintext]
  before_action :set_footer_visibility, only:   [:edit]

  # Skip UI-heavy calls for API endpoints
  skip_before_action :cache_most_used_page_information, only: [:update]
  skip_before_action :cache_forums_unread_counts,       only: [:update]

  # TODO: verify_user_can_read, verify_user_can_edit, etc before_actions instead of inlining them

  before_action :cache_linkable_content_for_each_content_type, only: [:edit]

  def index
    @page_title = "My documents"

    @recent_documents = current_user
      .linkable_documents.order('updated_at DESC')
      .includes([:user, :page_tags, :universe])
      .where(folder_id: nil)  # Only show documents not in folders
      .limit(10) # Limit for sidebar display

    # Apply sorting based on params
    @documents = current_user
      .linkable_documents
      .includes([:user, :page_tags, :universe])
      .where(folder_id: nil)  # Only show documents not in folders at root level

    case params[:sort]
    when 'alphabetical'
      @documents = @documents.order(favorite: :desc, title: :asc)
    when 'word_count'
      @documents = @documents.order(favorite: :desc).order(Arel.sql('cached_word_count DESC NULLS LAST'))
    when 'created'
      @documents = @documents.order(favorite: :desc, created_at: :desc)
    else # default to 'updated' or no param
      @documents = @documents.order(favorite: :desc, updated_at: :desc)
    end

    @folders = current_user
      .folders
      .where(context: 'Document', parent_folder_id: nil)
      .order('title ASC')
    
    # Apply global search if query param is present
    if params[:q].present?
      search_query = "%#{params[:q]}%"
      @documents = @documents.where("title ILIKE ? OR body ILIKE ?", search_query, search_query)
      @folders = @folders.where("title ILIKE ?", search_query)
    end

    # Calculate frequent folders (top 5 by document count)
    @frequent_folders = current_user
      .folders
      .where(context: 'Document')
      .joins(:documents)
      .group('folders.id')
      .order('COUNT(documents.id) DESC')
      .limit(5)

    # Note: Statistics are calculated directly in the view using @documents and @folders
    # which are already filtered to show only root-level items (folder_id: nil)

    # Calculate writing streak using WordCountUpdate
    calculate_writing_streak_data

    # Recent activity for feed
    @recent_activity = current_user.linkable_documents
      .order('updated_at DESC')
      .limit(10)
      .select(:id, :title, :updated_at, :cached_word_count, :user_id)

    # TODO: can we reuse this content to skip a few queries in this controller action?
    cache_linkable_content_for_each_content_type

    # TODO: all of this filtering code is repeated everywhere and would be nice to abstract out somewhere
    if params.key?(:favorite_only)
      @documents = @documents.where(favorite: true)
    end

    # Handle universe filtering from either @universe_scope or params[:universe_id]
    if @universe_scope
      @documents = @documents.where(universe: @universe_scope)
      @recent_documents = @recent_documents.where(universe: @universe_scope)
    elsif params[:universe_id].present?
      @documents = @documents.where(universe_id: params[:universe_id])
      @recent_documents = @recent_documents.where(universe_id: params[:universe_id])
    end

    @recent_documents = @recent_documents.limit(6)

    @page_tags = PageTag.where(
      page_type: Document.name,
      page_id:   @documents.map(&:id)
    ).order(:tag)

    @filtered_page_tags = []
    if params.key?(:tag)
      @filtered_page_tags = @page_tags.where(slug: params[:tag])
      @documents = @documents.to_a.select { |document| @filtered_page_tags.pluck(:page_id).include?(document.id) }
      # @documents = @documents.where(page_tags: { slug: params[:tag] })
    end

    @page_tags = @page_tags.uniq(&:tag)
    @suggested_page_tags = (@page_tags.pluck(:tag) + PageTagService.suggested_tags_for('Document')).uniq
  end

  def show
    unless @document.present? && (current_user || User.new).can_read?(@document)
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
    end

    if @document.user.nil? || @document.user.thredded_user_detail.moderation_state == "blocked"
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
    end

    # Put the focus on the document by removing Notebook.ai actions
    @navbar_actions = []
  end

  def analysis
    unless @document.present? && (current_user || User.new).can_read?(@document)
      redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
    end

    @analysis = @document.document_analysis.where.not(queued_at: nil).order('updated_at DESC').first

    @navbar_actions.unshift({
      label: (@document.name || 'Untitled document'),
      href: document_path(@document)
    })

    @navbar_actions.unshift({
      label: 'Analysis',
      href: analysis_document_path(@document)
    })
  end

  def queue_analysis
    return redirect_back(fallback_location: documents_path, notice: "That document doesn't exist!", status: :not_found) unless @document.present?
    return redirect_back(fallback_location: documents_path, notice: "Document analysis is a feature for Premium users.") unless @document.user.on_premium_plan?
    return redirect_back(fallback_location: documents_path, notice: "You don't have permission to do that!") unless @document.user == current_user
    
    @document.analyze!
    redirect_to analysis_document_path(@document)
  end

  # todo this function is an embarassment
  def link_entity
    # Preconditions lol
    unless (Rails.application.config.content_types[:all].map(&:name) + [Timeline.name, Document.name, Book.name]).include?(linked_entity_params[:entity_type])
      raise "Invalid entity type #{linked_entity_params[:entity_type]}"
    end

    # Take this out of the params upfront in case we need to modify the value (after creating one, for example)
    document_analysis_id = linked_entity_params[:document_analysis_id].to_i

    if (document_analysis_id == -1)
      # If there's no document analysis present, we're creating an entity without an associated analysis yet
      # So we just create a, uh, placeholder I guess
      document = Document.find_by(id: linked_entity_params[:document_id], user: current_user.id)
      analysis = Documents::Analysis::DocumentAnalysisService.create_placeholder_analysis(document)
      document_analysis_id = analysis.id

      # todo document entities might make more sense to be tied to documents instead of analyses
    end

    if (linked_entity_params[:document_entity_id].to_i == -1)
      # If we pass in an ID of -1, then we're adding a new DocumentEntity (rather than linking an existing one)
      # Therefore, we need to create one.
      document_analysis = DocumentAnalysis.joins(:document).find_by(
        id: document_analysis_id, 
        documents: { user: current_user }
      )
      raise "No document analysis found for id=#{document_analysis_id} / user=#{current_user.id}" if document_analysis.nil?      

      # Now that we have the analysis reference, we just create a new DocumentEntity on it for the associated page
      page = linked_entity_params[:entity_type].constantize.find(linked_entity_params[:entity_id]) # raises exception if not found :+1:

      # Check if already linked (prevent duplicates)
      existing_entity = document_analysis.document_entities.find_by(
        entity_type: linked_entity_params[:entity_type],
        entity_id:   linked_entity_params[:entity_id]
      )

      if existing_entity.present?
        # Already linked - return success but indicate it was already linked
        respond_to do |format|
          format.html { redirect_back(fallback_location: analysis_document_path(document_analysis.document), notice: "Page is already linked!") }
          format.json do
            render json: { success: true, already_linked: true, message: "#{page.name} is already linked to this document." }
          end
        end
        return
      end

      document_entity = document_analysis.document_entities.create!(
        entity_type: linked_entity_params[:entity_type],
        entity_id:   linked_entity_params[:entity_id],
        text:        page.name
      )

      # Finally, we need to kick off another analysis job to fetch information about this entity
      document_entity.analyze! if current_user.on_premium_plan?

      # Return JSON for AJAX requests, redirect for regular requests
      respond_to do |format|
        format.html { redirect_back(fallback_location: analysis_document_path(document_entity.document_analysis.document), notice: "Page linked!") }
        format.json do
          # Load the entity with its attributes for display
          entity = document_entity.entity
          entity_class = entity.class

          # Render the card partial as HTML for instant UI insertion
          card_html = render_to_string(
            partial: 'documents/linked_entity_card',
            locals: { document_entity: document_entity },
            formats: [:html]
          )

          render json: {
            success: true,
            card_html: card_html,
            document_entity: {
              id: document_entity.id,
              entity_type: document_entity.entity_type,
              entity_id: document_entity.entity_id,
              entity: {
                id: entity.id,
                name: entity.name,
                description: entity.try(:description),
                role: entity.try(:role),
                type_of: entity.try(:type_of),
                item_type: entity.try(:item_type),
                summary: entity.try(:summary),
                class_color: entity_class.color,
                class_text_color: entity_class.text_color,
                class_icon: entity_class.icon,
                class_name: entity_class.name,
                view_path: polymorphic_path(entity_class.name.downcase, id: entity.id)
              }
            }
          }
        end
      end
      
      return

    else
      # If we pass in an actual ID for the document entity, we're modifying an existing one
      document_entity = DocumentEntity.find_by(id: linked_entity_params[:document_entity_id].to_i)
      # todo some real perms?
      if document_entity && document_entity.document_owner == current_user
        # todo strong params update sans DEI?
        document_entity.update(
          entity_type: linked_entity_params[:entity_type], 
          entity_id:   linked_entity_params[:entity_id].to_i
        )

        respond_to do |format|
          format.html { redirect_to(analysis_document_path(document_entity.document_analysis.document), notice: "Page linked!") }
          format.json do
            entity = document_entity.entity
            entity_class = entity.class
            
            render json: {
              success: true,
              document_entity: {
                id: document_entity.id,
                entity_type: document_entity.entity_type,
                entity_id: document_entity.entity_id,
                entity: {
                  id: entity.id,
                  name: entity.name,
                  description: entity.try(:description),
                  role: entity.try(:role),
                  type_of: entity.try(:type_of),
                  item_type: entity.try(:item_type),
                  summary: entity.try(:summary),
                  class_color: entity_class.color,
                  class_text_color: entity_class.text_color,
                  class_icon: entity_class.icon,
                  class_name: entity_class.name,
                  view_path: polymorphic_path(entity_class.name.downcase, id: entity.id)
                }
              }
            }
          end
        end
        
        return
      end
    end
  end

  def new
    document = current_user.documents.create({
      universe:  @universe_scope,
      folder_id: params.fetch('folder', nil).try(:to_i)
    })
    redirect_to edit_document_path(document)
  end

  def edit
    redirect_to(root_path, notice: "You don't have permission to edit that!") unless @document.updatable_by?(current_user)

    # Fetch all document entities (linked and unlinked) with their associations
    @linked_entities = @document.document_entities
      .includes(:entity)
      .where.not(entity_id: nil)

    # Group by entity type for easier rendering
    @linked_entities_by_type = @linked_entities.group_by(&:entity_type)

    # Books sidebar data
    @document_books = @document.books.includes(book_documents: :document).order(:title)
    @user_books = current_user.books.unarchived.order(:title)
  end

  def create
    created_document = current_user.documents.create(document_params)
    redirect_to edit_document_path(created_document), notice: "Your document has been saved!"
  end

  def update
    document = Document.with_deleted.find_or_initialize_by(id: params[:id])

    unless document.updatable_by?(current_user)
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    # We can't pass actual-nil from HTML (for no universe), so we pass a string instead and convert it back here.
    d_params = document_params.clone
    if d_params.fetch(:universe_id, nil) == "nil"
      d_params[:universe_id] = nil
    end

    # Save the document first - this is critical and must succeed
    if document.update(d_params)
      # Update tags after successful save
      update_page_tags(document) if document_tag_params
      
      # Queue background jobs only after successful save, and fail gracefully if Redis is down
      begin
        # Only queue document mentions for analysis if the document body has changed
        DocumentMentionJob.perform_later(document.id) if d_params.key?(:body)
      rescue RedisClient::CannotConnectError, Redis::CannotConnectError => e
        # Log the error but don't fail the save - the document is already saved
        Rails.logger.warn "Could not queue DocumentMentionJob due to Redis connection error: #{e.message}"
      end
      
      head 200, content_type: "text/html"
    else
      head 501, content_type: "text/html"
    end
  end

  def plaintext
    unless @document.present? && (current_user || User.new).can_read?(@document)
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
    end

    render
  end

  def printable
    unless @document.present? && (current_user || User.new).can_read?(@document)
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.", status: :not_found)
    end

    render layout: 'printable'
  end

  def toggle_favorite
    document = Document.with_deleted.find_or_initialize_by(id: params[:id])

    unless document.updatable_by?(current_user)
      render json: { error: "You don't have permission to edit that!" }, status: :forbidden
      return
    end

    if document.update(favorite: !document.favorite)
      render json: { success: true, favorite: document.favorite }
    else
      render json: { error: "Failed to update favorite status" }, status: :unprocessable_entity
    end
  end

  def toggle_archive
    document = Document.find_by(id: params[:id])
    return head :not_found unless document.present?

    unless document.updatable_by?(current_user)
      respond_to do |format|
        format.html { redirect_to(root_path, notice: "You don't have permission to do that!") }
        format.json { render json: { error: "You don't have permission to do that!" }, status: :forbidden }
      end
      return
    end

    verb = document.archived? ? "unarchived" : "archived"
    success = document.archived? ? document.unarchive! : document.archive!

    respond_to do |format|
      if success
        format.html do
          if verb == "archived"
            redirect_to archive_path, notice: "Document archived."
          else
            redirect_to document, notice: "Document unarchived."
          end
        end
        format.json { render json: { success: true, archived: document.archived?, verb: verb } }
      else
        format.html { redirect_back(fallback_location: document, notice: "Failed to #{verb.chomp('d')} document.") }
        format.json { render json: { error: "Failed to #{verb.chomp('d')} document" }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if current_user.can_delete?(@document)
      @document.destroy
      redirect_to(documents_path, notice: "The document was successfully deleted.")
    else
      redirect_to(root_path, notice: "You don't have permission to do that!")
    end
  end

  def destroy_document_entity
    entity   = DocumentEntity.find_by(id: params[:id])
    document = entity.document_analysis.document
    return unless document.user == current_user

    entity.destroy

    redirect_back(fallback_location: analysis_document_path(document), notice: "Entity removed from analysis.")
  end

  def unlink_entity
    document = Document.find_by(id: params[:id])
    return unless document.present?

    entity   = document.document_entities.find_by(
      entity_type: params[:page_type],
      entity_id:   params[:page_id]
    )
    return unless entity.present?

    return unless user_signed_in? && document.user == current_user
    entity.destroy

    redirect_back(fallback_location: document, notice: "Page unlinked.")
  end

  def unlink_entity_by_id
    document = Document.find_by(id: params[:id])
    return head :not_found unless document.present?
    return head :unauthorized unless user_signed_in? && document.user == current_user

    entity = document.document_entities.find_by(id: params[:entity_id])
    return head :not_found unless entity.present?

    entity_name = entity.entity&.name || 'Page'
    entity.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: document, notice: "#{entity_name} unlinked.") }
      format.json { render json: { success: true, message: "#{entity_name} unlinked from document." } }
    end
  end

  def destroy_analysis
    # todo move this to analysis controller
    document = Document.find_by(id: params[:id])
    return unless document.user == current_user

    document.document_analysis.destroy_all

    redirect_back(fallback_location: analysis_document_path(document), notice: "Analysis deleted.")
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end

  def set_navbar_color
    content_type = content_type_from_controller(self.class)
    @navbar_color = content_type.hex_color
  end

  def set_navbar_actions
    @navbar_actions = []
  end

  def set_footer_visibility
    @show_footer = false
  end

  # Determines which layout to use based on the current action
  def determine_layout
    if action_name == 'edit'
      'editor'
    elsif action_name == 'plaintext'
      'plaintext'
    else
      'application' # Default layout for other actions
    end
  end

  private

  def calculate_writing_streak_data
    # Use user's timezone for date calculations
    user_today = current_user.current_date_in_time_zone

    # Today's word count (actual delta from yesterday)
    @words_written_today = WordCountUpdate.words_written_on_date(current_user, user_today)

    # This week's word count (actual delta from end of last week)
    @words_written_this_week = WordCountUpdate.words_written_in_range(
      current_user,
      user_today.beginning_of_week..user_today
    )
  end

  def update_page_tags(document)
    tag_list = document_tag_params.fetch('value', '').split(PageTag::SUBMISSION_DELIMITER)
    current_tags = document.page_tags.pluck(:tag)

    tags_to_add    = tag_list - current_tags
    tags_to_remove = current_tags - tag_list

    tags_to_add.each do |tag|
      # TODO: create changelog event for AddedTag
      document.page_tags.find_or_create_by(
        tag:  tag,
        slug: PageTagService.slug_for(tag),
        user: document.user
      )
    end

    tags_to_remove.each do |tag|
      # TODO: create changelog event for RemovedTag or use destroy_all
      document.page_tags.find_by(tag: tag).destroy
    end
  end

  def document_params
    params.require(:document).permit(:title, :body, :deleted_at, :privacy, :universe_id, :folder_id, :notes_text, :synopsis, :status)
  end

  def document_tag_params
    params.require(:field).permit(:value)
  rescue ActionController::ParameterMissing
    nil
  end

  def linked_entity_params
    params.permit(:entity_id, :entity_type, :document_entity_id, :document_id, :document_analysis_id)
  end

  def set_document
    @document = Document.find_by(id: params[:id])

    unless @document
      redirect_to root_path, notice: "Either that document doesn't exist or you don't have permission to view it!", status: :not_found
      return
    end
  end
end
