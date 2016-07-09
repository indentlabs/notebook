require 'test_helper'

# Tests for the CharactersController class
class CharactersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:tolkien)
    @universe = universes(:middleearth)

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
    assert_difference('Character.count') do
      post :create, character: {
        age: 'Created Age',
        name: 'Created Name',
        universe: @universe
      }
    end

    assert_redirected_to character_path(assigns(:content))
  end

  test 'should show character' do
    @character = characters(:frodo)

    get :show, id: @character.id
    assert_response :success
  end

  test 'should get edit' do
    @character = characters(:frodo)
    get :edit, id: @character.id
    assert_response :success
  end

  test 'should update character' do
    @character = characters(:frodo)

    put :update, id: @character, character: {
      age: @character.age,
      name: @character.name,
      universe: @universe
    }

    assert_response 302
    assert_redirected_to character_path(@character)
  end

  test 'should destroy character' do
    assert_difference('Character.count', -1) do
      delete :destroy, id: characters(:frodo).id
    end

    assert_redirected_to characters_url
  end
end
