class BooksController < ApplicationController
  # How many characters we pull from the database before privacy-filtering them
  # for the book's sidebar (see #readable_book_characters).
  CHARACTER_LOOKUP_LIMIT = 50

  before_action :authenticate_user!, except: [:show]
  before_action :set_book, except: [:index, :new, :create, :show]
  before_action :set_sidenav_expansion

  def index
    @books = current_user.books.unarchived.includes(:image_uploads)
    @books = @books.where(universe_id: @universe_scope.id) if @universe_scope.present?
    @books = @books.order(favorite: :desc, updated_at: :desc)
  end

  def show
    @book = Book.find_by(id: params[:id])
    
    if @book.nil?
      return redirect_to root_path, notice: "That book doesn't exist!"
    end

    unless (current_user || User.new).can_read?(@book)
      return redirect_to root_path, notice: "You don't have permission to view that book."
    end

    @book_documents = @book.book_documents.includes(:document).order(position: :asc)
    @total_words = @book_documents.sum { |bd| bd.document&.word_count.to_i }
    @est_reading_time = (@total_words / 200.0).ceil

    @characters, @characters_source = readable_book_characters
  end

  def new
    attrs = { name: 'Untitled Book' }
    attrs[:universe_id] = @universe_scope.id if @universe_scope.present?

    @book = current_user.books.create!(attrs)
    respond_to do |format|
      format.html { redirect_to edit_book_path(@book) }
      format.json { render json: { status: 'ok', book: { id: @book.id, name: @book.name } } }
    end
  end

  def create
    @book = current_user.books.new(book_params)
    @book.name = 'Untitled Book' if @book.name.blank?
    @book.universe_id ||= @universe_scope.id if @universe_scope.present?

    if @book.save
      respond_to do |format|
        format.html { redirect_to edit_book_path(@book) }
        format.json { render json: { id: @book.id, name: @book.name } }
      end
    else
      respond_to do |format|
        format.html { redirect_to books_path, alert: 'Failed to create book.' }
        format.json { render json: { errors: @book.errors }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @available_documents = current_user.documents.unarchived.order(:title)
    @book_documents = @book.book_documents.includes(:document).order(position: :asc)
  end

  def update
    if @book.update(book_params)
      respond_to do |format|
        format.html { redirect_to edit_book_path(@book), notice: 'Book updated.' }
        format.json { render json: { status: 'ok' } }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @book.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: 'Book deleted.'
  end

  def toggle_archive
    if @book.archived?
      @book.unarchive!
      respond_to do |format|
        format.html { redirect_to edit_book_path(@book) }
        format.json { render json: { success: true } }
      end
    else
      @book.archive!
      respond_to do |format|
        format.html { redirect_to archive_path }
        format.json { render json: { success: true } }
      end
    end
  end

  def toggle_favorite
    if @book.update(favorite: !@book.favorite)
      render json: { success: true, favorite: @book.favorite }
    else
      render json: { error: "Failed to update favorite status" }, status: :unprocessable_entity
    end
  end

  # Document management
  def add_document
    document = current_user.documents.find(params[:document_id])
    unless @book.book_documents.exists?(document: document)
      @book.book_documents.create(document: document)
    end

    @available_documents = current_user.documents.unarchived.order(:title)
    @book_documents = @book.book_documents.includes(:document).order(position: :asc)

    respond_to do |format|
      format.js
      format.html { redirect_to edit_book_path(@book) }
      format.json { render json: { status: 'ok' } }
    end
  end

  def remove_document
    @book.book_documents.find_by(document_id: params[:document_id])&.destroy

    @available_documents = current_user.documents.unarchived.order(:title)
    @book_documents = @book.book_documents.includes(:document).order(position: :asc)

    respond_to do |format|
      format.js
      format.html { redirect_to edit_book_path(@book) }
      format.json { render json: { status: 'ok' } }
    end
  end

  def sort_document
    book_document = @book.book_documents.find(params[:book_document_id])
    book_document.insert_at(params[:position].to_i + 1)
    render json: { status: 'ok' }
  end

  def create_document
    document = current_user.documents.create!(title: params[:title].presence || 'Untitled')
    @book.book_documents.create!(document: document)

    respond_to do |format|
      format.html { redirect_to edit_document_path(document) }
      format.json { render json: { status: 'ok', document: { id: document.id, title: document.title } } }
    end
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end

  def set_sidenav_expansion
    @sidenav_expansion = 'writing'
  end

  def book_params
    params.require(:book).permit(:name, :subtitle, :description, :blurb, :status, :privacy, :universe_id, image_uploads_attributes: [:id, :src, :privacy, :_destroy])
  end

  # Characters to show alongside a book, filtered down to the ones the current
  # viewer is allowed to see. Returns [characters, source], where source is
  # :book when the characters were detected in the book's own chapters, or
  # :universe when we fell back to everyone living in the book's universe.
  def readable_book_characters
    characters = characters_appearing_in_book
    source = :book

    if characters.empty? && @book.universe.present?
      characters = @book.universe.characters.unarchived.order(:name).limit(CHARACTER_LOOKUP_LIMIT)
      source = :universe
    end

    viewer = current_user || User.new
    [characters.select { |character| viewer.can_read?(character) }, source]
  end

  # Characters that document analysis has linked to one of this book's chapters.
  def characters_appearing_in_book
    document_ids = @book_documents.map(&:document_id).compact
    return [] if document_ids.empty?

    character_ids = DocumentEntity
      .joins(:document_analysis)
      .where(document_analyses: { document_id: document_ids })
      .where(entity_type: 'Character')
      .where.not(entity_id: nil)
      .distinct
      .pluck(:entity_id)
    return [] if character_ids.empty?

    Character.unarchived.where(id: character_ids).order(:name).limit(CHARACTER_LOOKUP_LIMIT)
  end
end
