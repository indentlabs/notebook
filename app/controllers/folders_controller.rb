class FoldersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_folder,              only: [:show, :destroy, :update]
  before_action :verify_folder_ownership, only: [:show, :destroy, :update]
  before_action :set_sidenav_expansion,   only: [:show]

  def create
    folder = Folder.create(folder_params.merge({ user: current_user }))
    redirect_back(fallback_location: documents_path, notice: "Folder #{folder.title} created!")
  end

  def update
    @folder.update(folder_params)

    redirect_back(fallback_location: folder_path(@folder), notice: "Folder #{@folder.title} updated!")
  end

  def destroy
    # Store parent folder reference before deletion for redirect logic
    parent_folder_id = @folder.parent_folder_id
    redirect_destination = if parent_folder_id
                            folder_path(parent_folder_id)
                          else
                            documents_path
                          end
    
    # Relocate all documents to parent folder (or root if no parent)
    Document.with_deleted.where(folder_id: @folder.id).update_all(folder_id: parent_folder_id)

    # Relocate all child folders to parent folder (or root if no parent)
    Folder.where(parent_folder_id: @folder.id).update_all(parent_folder_id: parent_folder_id)

    folder_name = @folder.title
    @folder.destroy!
    
    notice_message = if parent_folder_id
                      "Folder #{folder_name} deleted! All content moved to parent folder."
                    else
                      "Folder #{folder_name} deleted! All content moved to root."
                    end
    
    redirect_to(redirect_destination, notice: notice_message)
  end

  def show
    @page_title = @folder.title || 'Untitled folder'

    # Set up variables to match documents#index
    @recent_documents = current_user
      .linkable_documents.order('updated_at DESC')
      .includes([:user, :page_tags, :universe])
      .limit(10)

    # Get documents in this folder
    @documents = current_user
      .linkable_documents
      .includes([:user, :page_tags, :universe])
      .where(folder_id: @folder.id)

    # Apply sorting (same as documents#index)
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

    # Get subfolders
    @folders = current_user
      .folders
      .where(context: 'Document', parent_folder_id: @folder.id)
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

    # Calculate writing streak using WordCountUpdate (same as documents#index)
    calculate_writing_streak_data

    # Recent activity for feed
    @recent_activity = current_user.linkable_documents
      .order('updated_at DESC')
      .limit(10)
      .select(:id, :title, :updated_at, :cached_word_count, :user_id)

    cache_linkable_content_for_each_content_type

    # Filter by favorites if requested
    if params.key?(:favorite_only)
      @documents = @documents.where(favorite: true)
    end

    # Handle universe filtering
    if @universe_scope
      @documents = @documents.where(universe: @universe_scope)
      @recent_documents = @recent_documents.where(universe: @universe_scope)
    elsif params[:universe_id].present?
      @documents = @documents.where(universe_id: params[:universe_id])
      @recent_documents = @recent_documents.where(universe_id: params[:universe_id])
    end

    @recent_documents = @recent_documents.limit(6)

    # Handle page tags
    @page_tags = PageTag.where(
      page_type: Document.name,
      page_id:   @documents.map(&:id)
    ).order(:tag)

    @filtered_page_tags = []
    if params.key?(:tag)
      @filtered_page_tags = @page_tags.where(slug: params[:tag])
      @documents = @documents.to_a.select { |document| @filtered_page_tags.pluck(:page_id).include?(document.id) }
    end

    @page_tags = @page_tags.uniq(&:tag)
    @suggested_page_tags = (@page_tags.pluck(:tag) + PageTagService.suggested_tags_for('Document')).uniq

    # Store the current folder for use in the view
    @current_folder = @folder

    # Render the documents index view
    render 'documents/index'
  end

  private

  def calculate_writing_streak_data
    # Today's word count
    @words_written_today = WordCountUpdate
      .where(user: current_user, for_date: Date.current)
      .sum(:word_count)

    # This week's word count
    @words_written_this_week = WordCountUpdate
      .where(user: current_user, for_date: Date.current.beginning_of_week..Date.current)
      .sum(:word_count)
  end

  private

  def set_folder
    @folder = Folder.find_by(user: current_user, id: params.fetch(:id).to_i)

    unless @folder
      raise "No folder found with ID #{params.fetch(:id).to_i}"
    end
  end

  def verify_folder_ownership
    unless user_signed_in? && current_user == @folder.user
      raise "Trying to access someone else's folder: #{current_user.id} tried to access #{@folder.user_id}'s folder #{@folder.id}"
    end
  end

  def folder_params
    params.require(:folder).permit(:title, :context, :parent_folder_id)
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end
end
