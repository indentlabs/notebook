require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase
  setup do
    log_in_user(:one)
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:languages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create language" do
    assert_difference('Language.count', 1) do
      post :create, language: { name: "Created Language", universe: universes(:one)}
    end

    assert_redirected_to language_path(assigns(:language))
  end

  test "should show language" do
    get :show, id: languages(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: languages(:one).id
    assert_response :success
  end

  test "should update language" do
    put :update, id: languages(:one).id, language: { name: "Updated Language Name", universe: universes(:one) }
    
    assert_redirected_to language_path(languages(:one))
  end

  test "should destroy language" do
    assert_difference('Language.count', -1) do
      delete :destroy, id: languages(:one).id
    end

    assert_redirected_to language_list_url
  end
end
