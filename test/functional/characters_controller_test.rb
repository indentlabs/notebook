require 'test_helper'

class CharactersControllerTest < ActionController::TestCase
  setup do
    @user = create(:user)
    @session = create(:session)
    @universe = create(:universe)
    @character = build(:character, user: @user)
  end
  
  teardown do
    DatabaseCleaner.clean
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
      post :create, character: { age: @character.age, name: @character.name, universe: @universe}
    end

    assert_redirected_to character_path(assigns(:character))
  end

  test "should show character" do
    @character.save
    get :show, id: @character
    assert_response :success
  end

  test "should get edit" do
    @character.save
    get :edit, id: @character
    assert_response 302
    assert_redirected_to character_edit_path(@character)
  end

  test "should update character" do
    @character.save
    put :update, id: @character, character: { age: @character.age, name: @character.name, universe: @universe }
    
    assert_response 302
    assert_redirected_to character_path(@character)
  end

  test "should destroy character" do
    @character.save
    
    assert_difference('Character.count', -1) do
      delete :destroy, id: @character
    end
    
    get :show, id: @character
    assert_response 404

    assert_redirected_to characters_path
  end
end
