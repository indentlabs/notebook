require 'test_helper'

class BookAuthorizerTest < ActiveSupport::TestCase
  setup do
    @author   = User.first
    @stranger = User.last
    assert_not_equal(@author.id, @stranger.id, "Test problem: author and stranger need to be different users!")
  end

  def anonymous
    User.new
  end

  test "a book created without an explicit privacy is private" do
    book = Book.create!(user: @author, name: 'Untitled Book')

    assert_equal 'private', book.privacy
    assert_not book.effectively_public?
    assert_not book.public_content?
    assert book.private_content?
  end

  test "a book created without a universe is private" do
    book = Book.create!(user: @author, name: 'Untitled Book')

    assert_nil book.universe
    assert @author.can_read?(book)
    assert_not @stranger.can_read?(book)
    assert_not anonymous.can_read?(book)
  end

  test "a private book with no universe is excluded from the is_public scope" do
    # Guards the LEFT OUTER JOIN in HasPrivacy#is_public: a universe-less book
    # joins against a NULL universes.privacy, which must not match 'public'.
    book = Book.create!(user: @author, name: 'Untitled Book', privacy: 'private')

    assert_not_includes Book.is_public, book
  end

  test "a public book with no universe is readable by anyone" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')

    assert book.effectively_public?
    assert @stranger.can_read?(book)
    assert anonymous.can_read?(book)
    assert_includes Book.is_public, book
  end

  test "a private book in a private universe is not readable by others" do
    universe = Universe.create!(user: @author, name: 'Private Universe', privacy: 'private')
    book     = Book.create!(user: @author, name: 'My Book', privacy: 'private', universe: universe)

    assert_not book.effectively_public?
    assert_not @stranger.can_read?(book)
    assert_not anonymous.can_read?(book)
    assert_not_includes Book.is_public, book
  end

  test "a private book in a public universe is readable by anyone" do
    # Books inherit their universe's visibility: a public universe makes its
    # books readable even when the book's own privacy is still 'private'.
    universe = Universe.create!(user: @author, name: 'Public Universe', privacy: 'public')
    book     = Book.create!(user: @author, name: 'My Book', privacy: 'private', universe: universe)

    assert_equal 'private', book.privacy
    assert book.effectively_public?
    assert @stranger.can_read?(book)
    assert anonymous.can_read?(book)
    assert_includes Book.is_public, book
  end

  test "a public book grants read access only, not update or delete" do
    book = Book.create!(user: @author, name: 'My Book', privacy: 'public')

    assert_not @stranger.can_update?(book)
    assert_not @stranger.can_delete?(book)
    assert @author.can_update?(book)
    assert @author.can_delete?(book)
  end

  test "another user's private book is not readable" do
    book = Book.create!(user: @stranger, name: 'Not My Book', privacy: 'private')

    assert_not @author.can_read?(book)
    assert_not anonymous.can_read?(book)
  end
end
