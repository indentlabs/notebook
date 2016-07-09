require 'test_helper'

# Tests for the LocationsController class
class LocationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    
    @user = users(:tolkien)
    sign_in @user
  end
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @universe = universes(:middleearth)
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

  test 'should create location' do
    assert_difference('Location.count') do
      post :create, location: {
        name: 'Isengard',
        universe: @universe,
        user: @user
      }
    end

    assert_redirected_to location_path(assigns(:content))
  end

  test 'should show location' do
    @location = locations(:shire)

    get :show, id: @location.id
    assert_response :success
  end

  test 'should get edit' do
    @location = locations(:shire)
    get :edit, id: @location.id
    assert_response :success
  end

  test 'should update location' do
    @location = locations(:shire)
    put :update, id: @location, location: {
      name: 'Bag End',
      universe: @universe
    }

    assert_response 302
    assert_redirected_to location_path(@location)
  end

  test 'should destroy location' do
    assert_difference('Location.count', -1) do
      delete :destroy, id: locations(:shire).id
    end

    assert_redirected_to locations_url
  end

  test 'should create location with image' do
    assert_difference('Location.count') do
      map = fixture_file_upload('mordor_map.jpg', 'image/jpeg')
      post :create, location: {
        name: 'Mordor',
        map: map,
        universe: @universe,
        user: @user
      }
    end

    assert_redirected_to location_path(assigns(:content))
  end
end
