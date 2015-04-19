require 'test_helper'

# Tests for the LanguagesController class
class LanguagesControllerTest < ActionController::TestCase
  setup do
    log_in_user(:tolkien)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:languages)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create language' do
    assert_difference('Language.count', 1) do
      post :create, language: {
        name: 'Created Language',
        universe: universes(:middleearth)
      }
    end

    assert_redirected_to language_path(assigns(:language))
  end

  test 'should show language' do
    get :show, id: languages(:sindarin).id
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: languages(:sindarin).id
    assert_response :success
  end

  test 'should update language' do
    put :update, id: languages(:sindarin).id, language: {
      name: 'Updated Language Name',
      universe: universes(:middleearth)
    }

    assert_redirected_to language_path(languages(:sindarin))
  end

  test 'should destroy language' do
    assert_difference('Language.count', -1) do
      delete :destroy, id: languages(:sindarin).id
    end

    assert_redirected_to language_list_url
  end
end
