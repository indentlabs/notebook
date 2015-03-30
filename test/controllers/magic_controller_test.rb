require 'test_helper'

# Tests for the MagicController class
class MagicControllerTest < ActionController::TestCase
  setup do
    @user = users(:tolkien)
    @universe = universes(:middleearth)

    log_in_user(:tolkien)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:magics)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create magic' do
    assert_difference('Magic.count') do
      post :create, magic: { name: 'Magic Rings', universe: @universe }
    end

    assert_redirected_to magic_path(assigns(:magic))
  end

  test 'should show magic' do
    @magic = magics(:wizard)

    get :show, id: @magic.id
    assert_response :success
  end

  test 'should get edit' do
    @magic = magics(:wizard)
    get :edit, id: @magic.id
    assert_response :success
  end

  test 'should update magic' do
    @magic = magics(:wizard)
    put :update, id: @magic, magic: { name: 'Maiar Magic', universe: @universe }

    assert_response 302
    assert_redirected_to magic_path(@magic)
  end

  test 'should destroy magic' do
    assert_difference('Magic.count', -1) do
      delete :destroy, id: magics(:wizard).id
    end

    assert_redirected_to magic_list_url
  end
end
