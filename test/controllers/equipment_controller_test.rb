require 'test_helper'

class EquipmentControllerTest < ActionController::TestCase
  setup do
    log_in_user(:one)
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:equipment)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create equipment" do
    assert_difference('Equipment.count') do
      post :create, equipment: { name: "Created Equipment", universe: universes(:one)}
    end

    assert_redirected_to equipment_path(assigns(:equipment))
  end

  test "should show equipment" do
    get :show, id: equipment(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: equipment(:one).id
    assert_response :success
  end

  test "should update equipment" do
    put :update, id: equipment(:one).id, equipment: { name: "Updated Equipment Name", universe: universes(:one) }
    
    assert_response 302
    assert_redirected_to equipment_path(equipment(:one))
  end

  test "should destroy equipment" do
    assert_difference('Equipment.count', -1) do
      delete :destroy, id: equipment(:one).id
    end

    assert_redirected_to equipment_list_url
  end
end
