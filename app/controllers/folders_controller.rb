class FoldersController < ApplicationController
  layout 'tailwind'
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
    # Relocate all documents in this folder to the root "folder"
    # TODO - I think we can handle this at the model association level with dependent: nullify, but I've never used it
    Document.with_deleted.where(folder_id: @folder.id).update_all(folder_id: nil)

    # Relocate all child folders in this folder to the root "folder"
    Folder.where(parent_folder_id: @folder.id).update_all(parent_folder_id: nil)

    @folder.destroy!
    redirect_to(documents_path, notice: "Folder #{@folder.title} deleted!")
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
