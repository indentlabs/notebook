class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_book, except: [:index, :new, :create]
  before_action :set_sidenav_expansion

  def index
    @books = current_user.books.unarchived.order(updated_at: :desc)
    @archived_books = current_user.books.archived.order(updated_at: :desc)
  end

  def show
    # Public view (to be implemented later)
    redirect_to edit_book_path(@book)
  end

  def new
    @book = current_user.books.create!(title: 'Untitled Book')
    redirect_to edit_book_path(@book)
  end

  def edit
    @available_documents = current_user.documents.unarchived.order(:title)
    @book_documents = @book.book_documents.includes(:document)
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
    @book.archived? ? @book.unarchive! : @book.archive!
    redirect_to books_path
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
