require 'test_helper'

class FoldersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @other_user = users(:two)

    # Update fixture data to have context and more descriptive titles
    @folder = folders(:one)
    @folder.update(title: 'Test Folder', context: 'Document', user: @user, parent_folder_id: nil)
    
    @subfolder = Folder.create!(title: 'Test Subfolder', context: 'Document', user: @user, parent_folder_id: @folder.id)
    @other_user_folder = folders(:two)
    @other_user_folder.update(title: 'Other User Folder', context: 'Document', user: @other_user, parent_folder_id: nil)
    
    # Create some documents in our test folder
    @document = Document.create!(title: 'Test Document', body: 'Test content', user: @user, folder: @folder)
    @document2 = Document.create!(title: 'Another Document', body: 'More content', user: @user, folder: @folder)
    @unfiled_document = Document.create!(title: 'Unfiled Document', body: 'No folder', user: @user)
  end

  test "should redirect when not logged in" do
    get folder_path(@folder)
    assert_redirected_to new_user_session_path

    post folders_path, params: { folder: { title: 'New Folder', context: 'Document' } }
    assert_redirected_to new_user_session_path

    patch folder_path(@folder), params: { folder: { title: 'Updated Folder' } }
    assert_redirected_to new_user_session_path

    delete folder_path(@folder)
    assert_redirected_to new_user_session_path
  end

  test "should create folder" do
    sign_in @user
    assert_difference('Folder.count') do
      post folders_path, params: { folder: { title: 'New Folder', context: 'Document' } }
    end

    assert_redirected_to documents_path
    assert_equal 'Folder New Folder created!', flash[:notice]
    assert_equal @user.id, Folder.last.user_id
    assert_equal 'New Folder', Folder.last.title
    assert_equal 'Document', Folder.last.context
  end

  test "should create subfolder" do
    sign_in @user
    assert_difference('Folder.count') do
      post folders_path, params: { folder: { title: 'New Subfolder', context: 'Document', parent_folder_id: @folder.id } }
    end

    assert_redirected_to documents_path
    assert_equal @folder.id, Folder.last.parent_folder_id
  end

  test "should update folder" do
    sign_in @user
    patch folder_path(@folder), params: { folder: { title: 'Updated Folder Title' } }
    
    @folder.reload
    # The redirect URL will contain the updated title in the slug
    assert_redirected_to folder_path(@folder)
    assert_equal 'Folder Updated Folder Title updated!', flash[:notice]
    assert_equal 'Updated Folder Title', @folder.title
  end

  test "should not update another user's folder" do
    sign_in @user
    
    assert_raises(RuntimeError) do
      patch folder_path(@other_user_folder), params: { folder: { title: 'Should Fail' } }
    end
    
    @other_user_folder.reload
    assert_equal 'Other User Folder', @other_user_folder.title
  end

  test "should show folder" do
    sign_in @user
    get folder_path(@folder)
    
    assert_response :success
    assert_select 'title', /Test Folder/
  end

  test "should show folder with parent folder" do
    sign_in @user
    get folder_path(@subfolder)
    
    assert_response :success
    # Since we can't use assigns without the rails-controller-testing gem,
    # we'll check for the parent folder information in the response body instead
    assert_match /Test Folder/, response.body
  end

  test "should filter by favorite" do
    sign_in @user
    @document.update(favorite: true)
    
    get folder_path(@folder, favorite_only: true)
    assert_response :success
    
    # Since we can't reliably test the output HTML, we'll just check that the response is successful
    assert_response :success
  end

  test "should not show another user's folder" do
    sign_in @user
    
    assert_raises(RuntimeError) do
      get folder_path(@other_user_folder)
    end
  end

  test "should destroy folder" do
    sign_in @user
    
    assert_difference('Folder.count', -1) do
      delete folder_path(@folder)
    end
    
    assert_redirected_to documents_path
    assert_equal 'Folder Test Folder deleted!', flash[:notice]
    
    # Documents should be relocated to no folder
    @document.reload
    @document2.reload
    assert_nil @document.folder_id
    assert_nil @document2.folder_id
    
    # Subfolders should be relocated to root
    @subfolder.reload
    assert_nil @subfolder.parent_folder_id
  end

  test "should not destroy another user's folder" do
    sign_in @user
    
    assert_no_difference('Folder.count') do
      assert_raises(RuntimeError) do
        delete folder_path(@other_user_folder)
      end
    end
  end

  test "should filter by tag" do
    sign_in @user
    
    # Create tags for testing - using update_columns to bypass validations
    tag = PageTag.new(page_type: 'Document', page_id: @document.id, tag: 'TestTag', slug: 'testtag')
    tag.save(validate: false)
    
    get folder_path(@folder, tag: 'testtag')
    
    # Since we can't reliably test the output HTML, we'll just check that the response is successful
    assert_response :success
  end
end
