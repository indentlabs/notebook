require 'test_helper'

class BooksPrivacyNoticeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "edit page warns that a private book in a public universe is publicly visible" do
    universe = Universe.create!(user: @user, name: 'Public Universe', privacy: 'public')
    book     = Book.create!(user: @user, name: 'My Book', privacy: 'private', universe: universe)

    get edit_book_path(book)

    assert_response :success
    assert_match 'Make the universe private to restrict access', response.body
    assert_match 'inheritedPublic: true', response.body
  end

  test "edit page shows no inherited-visibility warning for a book in a private universe" do
    universe = Universe.create!(user: @user, name: 'Private Universe', privacy: 'private')
    book     = Book.create!(user: @user, name: 'My Book', privacy: 'private', universe: universe)

    get edit_book_path(book)

    assert_response :success
    assert_no_match 'Make the universe private to restrict access', response.body
    assert_match 'inheritedPublic: false', response.body
  end

  test "edit page shows no inherited-visibility warning for a book with no universe" do
    book = Book.create!(user: @user, name: 'My Book', privacy: 'private')

    get edit_book_path(book)

    assert_response :success
    assert_no_match 'Make the universe private to restrict access', response.body
    assert_match 'inheritedPublic: false', response.body
  end

  test "show page tells the author when a private book is public through its universe" do
    universe = Universe.create!(user: @user, name: 'Public Universe', privacy: 'public')
    book     = Book.create!(user: @user, name: 'My Book', privacy: 'private', universe: universe)

    get book_path(book)

    assert_response :success
    assert_match 'belongs to the public', response.body
  end

  test "show page tells the author a genuinely private book is private" do
    book = Book.create!(user: @user, name: 'My Book', privacy: 'private')

    get book_path(book)

    assert_response :success
    assert_match 'This book is private, so only you and collaborators can see it', response.body
    assert_no_match 'belongs to the public', response.body
  end
end
