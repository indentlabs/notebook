require 'test_helper'

class DocumentAuthorizerTest < ActiveSupport::TestCase
  setup do
    @author   = User.first
    @stranger = User.last
    assert_not_equal(@author.id, @stranger.id, "Test problem: author and stranger need to be different users!")

    @document = Document.create!(user: @author, title: 'Chapter One', privacy: 'private')
  end

  def anonymous
    User.new
  end

  test "private document with no books is not readable by others" do
    assert @author.can_read?(@document)
    assert_not @stranger.can_read?(@document)
    assert_not anonymous.can_read?(@document)
  end

  test "private document in a private book is not readable by others" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'private')
    book.book_documents.create!(document: @document)

    assert_not @stranger.can_read?(@document)
    assert_not anonymous.can_read?(@document)
  end

  test "private document in a public book is readable by anyone" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)

    assert @stranger.can_read?(@document)
    assert anonymous.can_read?(@document)
  end

  test "private document in two books is readable when any one of them is public" do
    private_book = Book.create!(user: @author, name: 'Private Book', privacy: 'private')
    public_book  = Book.create!(user: @author, name: 'Public Book',  privacy: 'public')
    private_book.book_documents.create!(document: @document)
    public_book.book_documents.create!(document: @document)

    assert @stranger.can_read?(@document)
    assert anonymous.can_read?(@document)
  end

  test "private document in a private book within a public universe is readable by anyone" do
    universe = Universe.create!(user: @author, name: 'Public Universe', privacy: 'public')
    book     = Book.create!(user: @author, name: 'My Book', privacy: 'private', universe: universe)
    book.book_documents.create!(document: @document)

    assert @stranger.can_read?(@document)
    assert anonymous.can_read?(@document)
  end

  test "removing a document from a public book restores its privacy" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book_document = book.book_documents.create!(document: @document)
    assert @stranger.can_read?(@document)

    book_document.destroy
    assert_not @stranger.can_read?(@document.reload)
  end

  test "making a public book private restores its documents' privacy" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)
    assert @stranger.can_read?(@document)

    book.update!(privacy: 'private')
    assert_not @stranger.can_read?(@document.reload)
  end

  test "soft-deleted public book does not expose its documents" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)
    assert @stranger.can_read?(@document)

    book.destroy
    assert_not @stranger.can_read?(@document.reload)
  end

  test "archived public book still exposes its documents" do
    # Archiving is organizational: an archived public book is still viewable
    # at its URL, so its chapters stay readable too.
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)
    book.archive!

    assert @stranger.can_read?(@document)
  end

  test "another user's public book does not expose a document they don't own" do
    book = Book.create!(user: @stranger, name: 'Not My Book', privacy: 'public')
    # Bypasses the controller (which only allows linking your own documents)
    # to guard against any future cross-user book membership feature.
    BookDocument.create!(book: book, document: @document)

    assert_not anonymous.can_read?(@document)
  end

  test "public book grants read access only, not update or delete" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)

    assert_not @stranger.can_update?(@document)
    assert_not @stranger.can_delete?(@document)
    assert @author.can_update?(@document)
    assert @author.can_delete?(@document)
  end

  test "public_content? reflects exposure through a public book" do
    assert_not @document.public_content?

    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')
    book.book_documents.create!(document: @document)

    assert @document.reload.public_content?
    assert @document.private_content? == false
  end

  test "effectively_public? matches book readability rules" do
    assert_not Book.create!(user: @author, name: 'Private Book', privacy: 'private').effectively_public?
    assert Book.create!(user: @author, name: 'Public Book', privacy: 'public').effectively_public?

    public_universe = Universe.create!(user: @author, name: 'Public Universe', privacy: 'public')
    assert Book.create!(user: @author, name: 'Universe Book', privacy: 'private', universe: public_universe).effectively_public?
  end
end
