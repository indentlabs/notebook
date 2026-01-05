class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, except: [:index, :new, :create]
  before_action :set_sidenav_expansion

  def index
    @books = current_user.books.unarchived.order(updated_at: :desc)
  end

  def show
    # Public view (to be implemented later)
    redirect_to edit_book_path(@book)
  end

  def new
    @book = current_user.books.create!(title: 'Untitled Book')
    respond_to do |format|
      format.html { redirect_to edit_book_path(@book) }
      format.json { render json: { status: 'ok', book: { id: @book.id, title: @book.title } } }
    end
  end

  def create
    @book = current_user.books.new(book_params)
    @book.title = 'Untitled Book' if @book.title.blank?

    if @book.save
      respond_to do |format|
        format.html { redirect_to edit_book_path(@book) }
        format.json { render json: { id: @book.id, title: @book.title } }
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

  # Document management
  def add_document
    document = current_user.documents.find(params[:document_id])
    unless @book.book_documents.exists?(document: document)
      @book.book_documents.create(document: document)
    end

    respond_to do |format|
      format.html { redirect_to edit_book_path(@book) }
      format.json { render json: { status: 'ok' } }
    end
  end

  def remove_document
    @book.book_documents.find_by(document_id: params[:document_id])&.destroy

    respond_to do |format|
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
      format.html { redirect_to edit_book_path(@book) }
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
    params.require(:book).permit(:title, :subtitle, :description, :blurb, :status, :privacy, :universe_id)
  end
end
