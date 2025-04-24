require 'test_helper'

class FolderTest < ActiveSupport::TestCase
  def setup
    @user = user(:starter)
    @parent_folder = Folder.create!(title: 'Parent Folder', user: @user)
    @folder = Folder.create!(title: 'Test Folder', user: @user, parent_folder: @parent_folder)
  end

  test "should be valid" do
    assert @folder.valid?
  end

  test "should require a user" do
    @folder.user = nil
    assert_not @folder.valid?
  end

  test "should have many documents" do
    assert_respond_to @folder, :documents
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @folder.documents
  end

  test "should belong to parent folder" do
    assert_respond_to @folder, :parent_folder
    assert_equal @parent_folder, @folder.parent_folder
  end

  test "should belong to user" do
    assert_respond_to @folder, :user
    assert_equal @user, @folder.user
  end

  test "child_folders should return folders with same user and parent" do
    child_folder = Folder.create!(title: 'Child Folder', user: @user, parent_folder: @folder)
    assert_includes @folder.child_folders, child_folder
  end

  test "class methods should return correct values" do
    assert_equal 'lighten-1 teal', Folder.color
    assert_equal 'text-lighten-1 teal-text', Folder.text_color
    assert_equal 'folder', Folder.icon
  end

  test "to_param should include id and slugged title" do
    expected_param = "#{@folder.id}-#{PageTagService.slug_for(@folder.title)}"
    assert_equal expected_param, @folder.to_param
  end
end
