class DocumentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :analysis]

  # todo Uh, this is a hack. The CSRF token on document editor model to add entities is being rejected... for whatever reason.
  skip_before_action :verify_authenticity_token, only: [:link_entity]

  before_action :set_document, only: [:show, :analysis, :queue_analysis, :continue, :edit, :destroy]
  before_action :set_sidenav_expansion
  before_action :set_navbar_color
  before_action :set_navbar_actions, except: [:edit]
  before_action :set_footer_visibility, only: [:edit]

  before_action :cache_linkable_content_for_each_content_type, only: [:edit]

  layout 'editor', only: [:edit]

  def index
    @documents = current_user.documents.order('updated_at desc')

    if @universe_scope.present?
      @documents = @documents.where(universe_id: @universe_scope.id)
    end
  end

  def show
    unless @document.present? && (current_user || User.new).can_read?(@document)
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.")
    end

    preload_linked_entities

    if @document.user == current_user
      @navbar_actions.unshift({
        label: 'Edit document',
        href: edit_document_path(@document),
        class: 'right '
      })
      @navbar_actions.unshift({
        label: 'Analyze document',
        href: analysis_document_path(@document),
        class: 'right'
      })
    end
    @navbar_actions.unshift({
      label: (@document.name || 'Untitled document'),
      href: document_path(@document)
    })
  end

  def analysis
    unless @document.present? && (current_user || User.new).can_read?(@document)
      redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.")
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
    return redirect_back(fallback_location: documents_path, notice: "That document doesn't exist!") unless @document.present?
    return redirect_back(fallback_location: documents_path, notice: "Document analysis is a feature for Premium users.") unless @document.user.on_premium_plan?
    return redirect_back(fallback_location: documents_path, notice: "You don't have permission to do that!") unless @document.user == current_user
    
    @document.analyze!
    redirect_to analysis_document_path(@document)
  end

  # todo this function is an embarassment
  def link_entity
    # Preconditions lol
    raise "Invalid entity type #{linked_entity_params[:entity_type]}" unless Rails.application.config.content_types[:all].map(&:name).include?(linked_entity_params[:entity_type])

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

      document_entity = document_analysis.document_entities.create!(
        entity_type: linked_entity_params[:entity_type],
        entity_id:   linked_entity_params[:entity_id],
        text:        page.name
      )

      # # Finally, we need to kick off another analysis job to fetch information about this entity
      document_entity.analyze! if current_user.on_premium_plan?

      return redirect_back(fallback_location: analysis_document_path(document_entity.document_analysis.document), notice: "Page linked!")

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

        return redirect_to(analysis_document_path(document_entity.document_analysis.document), notice: "Page linked!")
      end
    end
  end

  def new
    document = current_user.documents.create({universe: @universe_scope})
    redirect_to edit_document_path(document)
  end

  def edit
    preload_linked_entities

    @use_gpt = current_user.site_administrator?

    redirect_to(root_path, notice: "You don't have permission to edit that!") unless @document.updatable_by?(current_user)
  end

  # Todo does anything actually use this endpoint?
  def create
    created_document = current_user.documents.create(document_params)
    redirect_to edit_document_path(created_document), notice: "Your document has been saved!"
  end

  def update
    document = Document.with_deleted.find_or_initialize_by(id: params[:id])
    d_params = document_params.clone

    unless document.updatable_by?(current_user)
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    # Only queue document mentions for analysis if the document body has changed
    DocumentMentionJob.perform_later(document.id) if d_params.key?(:body)

    # We can't pass actual-nil from HTML (for no universe), so we pass a string instead and convert it back here.
    if d_params.fetch(:universe_id, nil) == "nil"
      d_params[:universe_id] = nil
    end

    if document.update(d_params)
      head 200, content_type: "text/html"
    else
      head 501, content_type: "text/html"
    end
  end

  def toggle_favorite
    document = Document.with_deleted.find_or_initialize_by(id: params[:id])

    unless document.updatable_by?(current_user)
      flash[:notice] = "You don't have permission to edit that!"
      return redirect_back fallback_location: document
    end

    document.update!(favorite: !document.favorite)
  end

  def continue
    return unless current_user.site_administrator?

    render json: Openai::Gpt3Service.autocomplete("#{@document.title}\nby #{@document.user.display_name}\n\n" + params.require(:prompt))
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

  def destroy_analysis
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
    return unless user_signed_in?

    if @current_user_content && @current_user_content['Document'].present?
      @navbar_actions << {
        label: "Your #{@current_user_content['Document'].count} Document#{'s' unless @navbar_actions == 1}",
        href: documents_path
      }
    end

    @navbar_actions << {
      label: "New Document",
      href: new_document_path,
      target: '_blank'
    }
  end

  def set_footer_visibility
    @show_footer = false
  end

  private

  def document_params
    params.require(:document).permit(:title, :body, :deleted_at, :privacy, :universe_id, :notes_text)
  end

  def linked_entity_params
    params.permit(:entity_id, :entity_type, :document_entity_id, :document_id, :document_analysis_id)
  end

  def preload_linked_entities
    # Simpler form: (8/6/19 left intact for temporary reference during release -- can delete after release)
    # @linked_entities = @document.document_entities
    #   .where.not(entity_id: nil)
    #   .includes(:entity)
    #   .order('entity_type asc')

    # More complicated includes-stuff form:
    @linked_entities = []
    return unless user_signed_in? && current_user.on_premium_plan?
    
    Rails.application.config.content_types[:all].each do |content_type|
      @linked_entities += @document.document_entities
        .where(entity_type: content_type.name)
        .where.not(entity_id: nil)
        .order('text ASC')
        .includes(:entity, entity: [:user])
        .includes(entity: Rails.application.config.inverse_content_relations.fetch(content_type.name, []).map do |relation, data|
          data[:inverse_class] == content_type.name ? data[:with] : nil
        end.compact)
    end
  end

  def set_document
    @document = Document.find_by(id: params[:id])
  end
end
