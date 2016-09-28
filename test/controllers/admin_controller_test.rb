require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get dashboard" do
    get :dashboard
    assert_response :success
  end

  test "should get universes" do
    get :universes
    assert_response :success
  end

  test "should get characters" do
    get :characters
    assert_response :success
  end

  test "should get locations" do
    get :locations
    assert_response :success
  end

  test "should get items" do
    get :items
    assert_response :success
  end

end
