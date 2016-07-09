require 'test_helper'

# Tests for the UniversesController
class UniversesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    
    @user = users(:tolkien)
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
    assert_difference('Universe.count') do
      post :create, universe: { name: 'Hyrule' }
    end

    assert_redirected_to universe_path(assigns(:content))
  end

  test 'should show universe' do
    @universe = universes(:middleearth)

    get :show, id: @universe.id
    assert_response :success
  end

  test 'should get edit' do
    @universe = universes(:middleearth)
    get :edit, id: @universe.id
    assert_response :success
  end

  test 'should update universe' do
    @universe = universes(:middleearth)
    put :update, id: @universe, universe: { name: 'Arda' }

    assert_response 302
    assert_redirected_to universe_path(@universe)
  end

  test 'should destroy universe' do # MWAHAHAHAHAHA!!!!!!!
    assert_difference('Universe.count', -1) do
      delete :destroy, id: universes(:middleearth).id
    end

    assert_redirected_to universes_url
  end
end
