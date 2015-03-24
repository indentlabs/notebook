require 'test_helper'

class LocationsControllerTest < ActionController::TestCase
  setup do
    @user = users(:tolkien)
    @universe = universes(:middleearth)
    
    log_in_user(:tolkien)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:locations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location" do
    assert_difference('Location.count') do
      post :create, location: { name: "Isengard", universe: @universe, user: @user}
    end

    assert_redirected_to location_path(assigns(:location))
  end

  test "should show location" do
    @location = locations(:shire)
    
    get :show, id: @location.id
    assert_response :success
  end

  test "should get edit" do
    @location = locations(:shire)
    get :edit, id: @location.id
    assert_response :success
  end

  test "should update location" do
    @location = locations(:shire)
    put :update, id: @location, location: { name: "Bag End", universe: @universe }
    
    assert_response 302
    assert_redirected_to location_path(@location)
  end

  test "should destroy location" do
    assert_difference('Location.count', -1) do
      delete :destroy, id: locations(:shire).id
    end

    assert_redirected_to location_list_url
  end
  
  test "should create location with image" do
    assert_difference('Location.count') do
      map = fixture_file_upload('mordor_map.jpg', 'image/jpeg')
      post :create, location: { name: 'Mordor', map: map, universe: @universe, user: @user }
    end
    
    assert_redirected_to location_path(assigns(:location))
  end
  
  test "should reject images with an invalid type" do
    assert_no_difference('Location.count') do
      map = fixture_file_upload('mordor_map.jpg', 'invalid/notanimage')
      post :create, location: { name: 'Mordor', map: map, universe: @universe, user: @user }
    end
  end
  
  test "should reject images with an empty type" do
    assert_no_difference('Location.count') do
      map = fixture_file_upload('mordor_map.jpg', '')
      post :create, location: { name: 'Mordor', map: map, universe: @universe, user: @user }
    end
  end
end