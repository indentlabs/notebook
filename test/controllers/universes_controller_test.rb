require 'test_helper'

# Tests for the UniversesController
class UniversesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    @user = create(:user)
    sign_in @user
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:content)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create universe' do
    universe = build(:universe, user: @user)

    assert_difference('Universe.count') do
      post :create, universe: { name: universe.name }
    end

    assert_redirected_to universe_path(assigns(:content))
  end

  test 'should show universe' do
    universe = create(:universe, user: @user)

    get :show, id: universe.id
    assert_response :success
  end

  test 'should get edit' do
    universe = create(:universe, user: @user)

    get :edit, id: universe.id
    assert_response :success
  end

  test 'should update universe' do
    universe = create(:universe, user: @user)

    put :update, id: universe.id, universe: { name: universe.name + ' Updated' }

    assert_response 302
    assert_redirected_to universe_path(universe)
  end

  test 'should destroy universe' do # MWAHAHAHAHAHA!!!!!!!
    universe = create(:universe, user: @user)

    assert_difference('Universe.count', -1) do
      delete :destroy, id: universe.id
    end

    assert_redirected_to universes_url
  end
end
