require 'test_helper'

# Tests for the CharactersController class
class CharactersControllerTest < ActionController::TestCase
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

  test 'should create character' do
    character = build(:character, universe: @universe, age: 70)
    
    assert_difference('Character.count') do
      post :create, character: {
        age: character.age,
        name: character.name,
        universe: character.universe
      }
    end

    assert_redirected_to character_path(assigns(:content))
  end

  test 'should show character' do
    character = create(:character, user: @user)

    get :show, id: character.id
    assert_response :success
  end

  test 'should get edit' do
    character = create(:character, user: @user)
    
    get :edit, id: character.id
    assert_response :success
  end

  test 'should update character' do
    character = create(:character, age: 70, universe: @universe, user: @user)

    put :update, id: character.id, character: {
      age: character.age,
      name: character.name,
      universe: character.universe
    }

    assert_response 302
    assert_redirected_to character_path(character)
  end

  test 'should destroy character' do
    character = create(:character, user: @user)
    
    assert_difference('Character.count', -1) do
      delete :destroy, id: character.id
    end

    assert_redirected_to characters_url
  end
end
