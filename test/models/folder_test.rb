require 'test_helper'

class FolderTest < ActiveSupport::TestCase
  def setup
    @user = user(:starter)
    @other_user = user(:premium)
    @parent_folder = Folder.create!(title: 'Parent Folder', user: @user)
    @folder = Folder.create!(title: 'Test Folder', user: @user, parent_folder: @parent_folder)
  end

  # Basic validation tests
  test "should be valid with required attributes" do
    assert @folder.valid?
  end

  test "should require a user" do
    @folder.user = nil
    assert_not @folder.valid?
    assert_includes @folder.errors[:user], "must exist"
  end

  test "should be valid without a parent folder" do
    top_level_folder = Folder.new(title: 'Top Level', user: @user)
    assert top_level_folder.valid?
  end

  # Association tests
  test "should have many documents" do
    assert_respond_to @folder, :documents
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @folder.documents
  end

  test "documents association should work" do
    document = Document.create!(title: 'Test Document', user: @user)
    @folder.documents << document
    assert_includes @folder.documents, document
    assert_equal @folder, document.folder
  end

  test "should belong to parent folder" do
    assert_respond_to @folder, :parent_folder
    assert_equal @parent_folder, @folder.parent_folder
  end

  test "should belong to user" do
    assert_respond_to @folder, :user
    assert_equal @user, @folder.user
  end

  # Child folders tests with edge cases
  test "child_folders should return folders with same user and parent" do
    child_folder = Folder.create!(title: 'Child Folder', user: @user, parent_folder: @folder)
    assert_includes @folder.child_folders, child_folder
  end

  test "child_folders should not return folders from different users" do
    other_user_folder = Folder.create!(title: 'Other User Folder', user: @other_user, parent_folder: @folder)
    assert_not_includes @folder.child_folders, other_user_folder
  end

  test "child_folders should not return folders with different parents" do
    other_parent = Folder.create!(title: 'Other Parent', user: @user)
    different_parent_folder = Folder.create!(title: 'Different Parent', user: @user, parent_folder: other_parent)
    assert_not_includes @folder.child_folders, different_parent_folder
  end

  # to_param tests with semantic checks
  test "to_param should include id and slugged title" do
    param = @folder.to_param
    assert_match(/^\d+-[\w-]+$/, param)
    assert_includes param, @folder.id.to_s
  end

  test "to_param should handle special characters in title" do
    folder = Folder.create!(title: 'Test & Folder!', user: @user)
    param = folder.to_param
    assert_match(/^\d+-[\w-]+$/, param)
    assert_includes param, folder.id.to_s
  end
end
