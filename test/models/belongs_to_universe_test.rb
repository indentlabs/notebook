require 'test_helper'

class BelongsToUniverseTest < ActiveSupport::TestCase
  setup do
    @owner    = users(:one)
    @other    = users(:two)
    @universe = Universe.create!(user: @other, name: 'Theirs', privacy: 'private')
  end

  test "a page can go in its owner's universe" do
    mine = Universe.create!(user: @owner, name: 'Mine', privacy: 'private')

    assert Character.new(user: @owner, name: 'Page', universe: mine).valid?
  end

  test "a page can go in a universe its owner contributes to" do
    Contributor.create!(universe: @universe, user: @owner, email: @owner.email)

    assert Character.new(user: @owner, name: 'Page', universe: @universe).valid?
  end

  test "a page can't go in someone else's universe" do
    page = Character.new(user: @owner, name: 'Page', universe: @universe)

    assert_not page.valid?
    assert page.errors.key?(:universe)
  end

  test "the rule covers every kind of page in a universe" do
    assert_not Book.new(user: @owner, name: 'Book', universe: @universe).valid?
    assert_not Document.new(user: @owner, title: 'Document', universe: @universe).valid?
    assert_not Timeline.new(user: @owner, name: 'Timeline', universe: @universe).valid?
  end

  test "a page stays editable after its owner stops contributing to the universe" do
    contributor = Contributor.create!(universe: @universe, user: @owner, email: @owner.email)
    page = Character.create!(user: @owner, name: 'Page', universe: @universe)
    contributor.destroy

    page = Character.find(page.id)
    assert page.update(name: 'Renamed')
  end

  test "a document can't go in someone else's folder" do
    folder   = Folder.create!(user: @other, title: 'Theirs', context: 'Document')
    document = Document.new(user: @owner, title: 'Mine', folder: folder)

    assert_not document.valid?
    assert document.errors.key?(:folder)
  end
end
