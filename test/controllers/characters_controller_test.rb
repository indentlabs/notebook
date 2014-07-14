require 'test_helper'

class CharactersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    @universe = universes(:one)
    
    session[:user] = users(:one).id
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:characters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create character" do
    assert_difference('Character.count') do
      post :create, character: { age: "Created Age", name: "Created Name", universe: @universe}
    end

    assert_redirected_to character_path(assigns(:character))
  end

  test "should show character" do
    @character = characters(:one)
    
    get :show, id: @character.id
    assert_response :success
  end

  test "should get edit" do
    @character = characters(:one)
    get :edit, id: @character.id
    assert_response :success
  end

  test "should update character" do
    @character = characters(:one)
    put :update, id: @character, character: { age: @character.age, name: @character.name, universe: @universe }
    
    assert_response 302
    assert_redirected_to character_path(@character)
  end

  test "should destroy character" do
    assert_difference('Character.count', -1) do
      delete :destroy, id: characters(:one).id
    end

    assert_redirected_to character_list_url
  end
end
