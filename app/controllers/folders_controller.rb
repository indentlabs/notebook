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

    @parent_folder = @folder.parent_folder
    @child_folders = Folder.where(parent_folder: @folder)
      .order('title ASC')

    # TODO: probably want to cache this in @current_user_content if we need it anywhere else
    @all_folders = current_user.folders
      .where(context: 'Document')
      .order('title ASC')

    # TODO: can we reuse this content to skip a few queries in this controller action?
    cache_linkable_content_for_each_content_type

    # Get the content type class based on the folder's context
    content_type_class = @folder.context.constantize rescue Document
    
    # Add sidebar data
    # Recent items and folders for sidebars (matching documents#index)
    if @folder.context == 'Document'
      @recent_documents = current_user.linkable_documents
        .order('updated_at DESC')
        .includes([:user, :page_tags, :universe])
        .limit(10)
    else
      # For other content types, load recent items
      @recent_documents = content_type_class
        .where(user: current_user)
        .order('updated_at DESC')
        .limit(10) rescue []
    end

    @frequent_folders = current_user.folders
      .where(context: @folder.context)
      .joins("LEFT JOIN #{content_type_class.table_name} ON #{content_type_class.table_name}.folder_id = folders.id")
      .group('folders.id')
      .order("COUNT(#{content_type_class.table_name}.id) DESC")
      .limit(5)
    
    # Calculate quick actions based on folder context
    @quick_actions = []
    if @folder.context == 'Document'
      @quick_actions << { label: 'New Document', path: new_document_path(folder: @folder.id), icon: 'add', color: 'blue' }
    elsif Rails.application.config.content_types[:all].map(&:name).include?(@folder.context)
      content_klass = content_class_from_name(@folder.context)
      @quick_actions << { 
        label: "New #{@folder.context}", 
        path: new_polymorphic_path(content_klass, folder: @folder.id), 
        icon: content_klass.icon, 
        color: content_klass.hex_color 
      }
    end
    @quick_actions << { label: 'New Subfolder', action: 'showNewFolderModal = true', icon: 'create_new_folder', color: Folder.hex_color }
    
    # Folder statistics (for right sidebar)
    @total_items_in_folder = 0
    @total_words_in_folder = 0
    
    # Check if the content type has a folder association
    if content_type_class.column_names.include?('folder_id')
      # Load content of the appropriate type
      @content = content_type_class.where(folder: @folder)
      
      # Add includes based on available associations
      includes_array = [:user]
      includes_array << :page_tags if content_type_class.reflect_on_association(:page_tags)
      includes_array << :universe if content_type_class.reflect_on_association(:universe)
      
      @content = @content.includes(includes_array)
        .order("#{content_type_class.table_name}.favorite DESC, #{content_type_class.table_name}.title ASC, #{content_type_class.table_name}.updated_at DESC")

      # Only filter by universe if the content type has a universe association
      if @universe_scope && content_type_class.reflect_on_association(:universe)
        @content = @content.where(universe: @universe_scope)
      end
    else
      # If the content type doesn't have a folder association, return an empty array
      @content = []
      Rails.logger.warn("Content type #{content_type_class.name} doesn't have a folder_id column")
    end

    if params.key?(:favorite_only)
      @content = @content.where(favorite: true)
    end

    # Handle page tags if content has any IDs
    if @content.any?
      @page_tags = PageTag.where(
        page_type: content_type_class.name,
        page_id:   @content.pluck(:id)
      ).order(:tag)

      if params.key?(:tag)
        @filtered_page_tags = @page_tags.where(slug: params[:tag])

        @content = @content.to_a.select { |content| @filtered_page_tags.pluck(:page_id).include?(content.id) }
        # TODO: the above could probably be replaced with something like the below, but not sure on nesting syntax
        # @content = @content.where(page_tags: { slug: @filtered_page_tags.pluck(:slug) })
      end

      @page_tags = @page_tags.uniq(&:tag)
      @suggested_page_tags = (@page_tags.pluck(:slug) + PageTagService.suggested_tags_for(content_type_class.name)).uniq
    else
      @page_tags = []
      @suggested_page_tags = PageTagService.suggested_tags_for(content_type_class.name)
    end
    
    # Make the content type class available to the view
    @content_type_class = content_type_class
    
    # Calculate folder statistics after content is loaded
    if @content.respond_to?(:count)
      @total_items_in_folder = @content.count
      if content_type_class.column_names.include?('cached_word_count')
        @total_words_in_folder = @content.sum(:cached_word_count) || 0
      end
    end
    
    # Activity stats (for right sidebar)
    @words_written_today = WordCountUpdate.where(
      user: current_user,
      for_date: Date.current
    ).sum(:word_count)

    @words_written_this_week = WordCountUpdate.where(
      user: current_user,
      for_date: Date.current.beginning_of_week..Date.current
    ).sum(:word_count)

    # Activity stats
    @items_this_month = 0
    if @content.any? && content_type_class.column_names.include?('created_at')
      @items_this_month = @content.where('created_at >= ?', Date.current.beginning_of_month).count
    end
    
    # Last activity in folder
    @last_activity = nil
    if @content.any? && content_type_class.column_names.include?('updated_at')
      @last_activity = @content.maximum(:updated_at)
    end
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
