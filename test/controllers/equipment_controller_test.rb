require 'test_helper'

# Tests for the EquipmentController class
class EquipmentControllerTest < ActionController::TestCase
  setup do
    log_in_user(:tolkien)
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

  test 'should create equipment' do
    assert_difference('Equipment.count') do
      post :create, equipment: {
        name: 'Created Equipment',
        universe: universes(:middleearth)
      }
    end

    assert_redirected_to equipment_path(assigns(:content))
  end

  test 'should show equipment' do
    get :show, id: equipment(:sting).id
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: equipment(:sting).id
    assert_response :success
  end

  test 'should update equipment' do
    put :update, id: equipment(:sting).id, equipment: {
      name: 'Updated Equipment Name',
      universe: universes(:middleearth)
    }

    assert_response 302
    assert_redirected_to equipment_path(equipment(:sting))
  end

  test 'should destroy equipment' do
    assert_difference('Equipment.count', -1) do
      delete :destroy, id: equipment(:sting).id
    end

    assert_redirected_to equipment_list_url
  end
end
