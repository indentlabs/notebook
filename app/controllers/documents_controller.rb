class DocumentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :analysis]

  before_action :set_sidenav_expansion
  before_action :set_navbar_color
  before_action :set_navbar_actions, except: [:edit]
  before_action :set_footer_visibility, only: [:edit]

  before_action :cache_linkable_content_for_each_content_type, only: [:edit]

  layout 'editor', only: [:edit]

  def index
    @documents = current_user.documents.order('updated_at desc')
  end

  def show
    @document = Document.find_by(id: params[:id])

    unless @document.present? && (current_user || User.new).can_read?(@document)
      return redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.")
    end

    @navbar_actions.unshift({
      label: (@document.name || 'Untitled document'),
      href: document_path(@document)
    })
  end

  def analysis
    # TODO uncomment this before it goes to production to limit analysis to document owners
    @document = Document.find_by(id: params[:id])#, user_id: current_user.id)

    # TODO undo commenting this before it goes to production; it's commented out for private demos
    # unless @document.present? && (current_user || User.new).can_read?(@document)
    #   redirect_to(root_path, notice: "That document either doesn't exist or you don't have permission to view it.")
    # end

    @analysis = @document.document_analysis.order('updated_at DESC').first

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
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
    return redirect_back(fallback_location: documents_path, notice: "That document doesn't exist!") unless @document.present?
    return redirect_back(fallback_location: documents_path, notice: "Document analysis is a feature for Premium users.") unless @document.user.on_premium_plan?
    return redirect_back(fallback_location: documents_path, notice: "You don't have permission to do that!") unless @document.user == current_user
    
    @document.analyze!
    redirect_to analysis_document_path(@document)
  end

  def link_entity
    # Preconditions lol
    raise "Invalid entity type #{linked_entity_params[:entity_type]}" unless Rails.application.config.content_types[:all].map(&:name).include?(linked_entity_params[:entity_type])

    if (linked_entity_params[:document_entity_id].to_i == -1)
      # If we pass in an ID of -1, then we're adding a new DocumentEntity (rather than linking an existing one)
      # Therefore, we need to create one.
      document_analysis = DocumentAnalysis.joins(:document).find_by(
        id: linked_entity_params[:document_analysis_id].to_i, 
        documents: { user: current_user }
      )
      raise "No document analysis found for id=#{linked_entity_params[:document_analysis_id]} / user=#{current_user.id}" if document_analysis.nil?      

      # Now that we have the analysis reference, we just create a new DocumentEntity on it for the associated page
      page = linked_entity_params[:entity_type].constantize.find(linked_entity_params[:entity_id]) # raises exception if not found :+1:

      document_entity = document_analysis.document_entities.create!(
        entity_type: linked_entity_params[:entity_type],
        entity_id:   linked_entity_params[:entity_id],
        text:        page.name
      )

      # Finally, we need to kick off another analysis job to fetch information about this entity
      document_entity.analyze!

      return redirect_to(analysis_document_path(document_entity.document_analysis.document), notice: "Page linked!")

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

  def edit
    @document = Document.find_by(id: params[:id], user_id: current_user.id)
    @document ||= current_user.documents.create

    # This eases documents from the old editor into the new one, replacing \n with <br>s
    # Todo this line can be removed after running a migration that updates all existing documents, since you can no longer create a document with raw newlines
    @document.update(body: @document.body.gsub("\n", "<br />")) if @document.body.present? && @document.body.include?("\n")

    redirect_to root_path unless @document.updatable_by?(current_user)
  end

  def create
    created_document = current_user.documents.create(document_params)
    redirect_to edit_document_path(created_document), notice: "Your document has been saved!"
  end

  def update
    document = Document.with_deleted.find_or_initialize_by(id: params[:id], user: current_user)

    unless document.user == current_user
      redirect_to(dashboard_path, notice: "You don't have permission to do that!")
      return
    end

    if document.updatable_by?(current_user) && document.update(document_params)
      head 200, content_type: "text/html"
    else
      head 501, content_type: "text/html"
    end
  end

  def destroy
    document = Document.find_by(id: params[:id])

    if current_user.can_delete?(document)
      document.destroy
      redirect_to(documents_path, notice: "The document was successfully deleted.")
    else
      redirect_to(root_path, notice: "You don't have permission to do that!")
    end
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
      href: edit_document_path(:new),
      target: '_blank'
    }
  end

  def set_footer_visibility
    @show_footer = false
  end

  private

  def document_params
    params.require(:document).permit(:title, :body, :deleted_at, :privacy)
  end

  def linked_entity_params
    params.permit(:entity_id, :entity_type, :document_entity_id, :document_id, :document_analysis_id)
  end
end
