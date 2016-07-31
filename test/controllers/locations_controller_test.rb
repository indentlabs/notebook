require 'test_helper'

# Tests for the LocationsController class
class LocationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user)
    @universe = create(:universe, user: @user)
    
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
    location = build(:location, user: @user)
    
    assert_difference('Location.count') do
      post :create, location: {
        name: location.name,
        universe: @universe,
        user: @user
      }
    end

    assert_redirected_to location_path(assigns(:content))
  end

  test 'should show location' do
    location = create(:location, user: @user)

    get :show, id: location
    assert_response :success
  end

  test 'should get edit' do
    location = create(:location, user: @user)
    
    get :edit, id: location.id
    assert_response :success
  end

  test 'should update location' do
    location = create(:location, user: @user)
    
    put :update, id: location, location: {
      name: location.name + ' Updated',
      universe: @universe
    }

    assert_response 302
    assert_redirected_to location_path(location)
  end

  test 'should destroy location' do
    location = create(:location, user: @user)
    
    assert_difference('Location.count', -1) do
      delete :destroy, id: location.id
    end

    assert_redirected_to locations_url
  end

  test 'should create location with image' do
    location = build(:location)
    
    assert_difference('Location.count') do
      map = fixture_file_upload('mordor_map.jpg', 'image/jpeg')
      post :create, location: {
        name: location.name,
        map: map,
        universe: @universe,
        user: @user
      }
    end

    assert_redirected_to location_path(assigns(:content))
  end
end
