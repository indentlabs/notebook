require 'rails_helper'
require 'support/devise'

RSpec.describe CharactersController, :type => :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = create(:user)

    sign_in @user
  end

  let(:universe) { create(:universe, user: @user) }
  let(:character) { create(:character, user: @user, universe: universe) }

  describe 'GET #index' do
    before { get :index }
    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('content/index') }

    describe 'assigns(:content)' do
      subject { assigns(:content) }
      it { is_expected.to_not be_nil }
    end
  end

  describe 'GET #new' do
    before { get :new }
    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('characters/new') }
  end

  describe 'POST #create' do
    before do
      post :create, character: {
        age: character.age,
        name: character.name,
        universe: character.universe
      }

    end
    it { is_expected.to redirect_to(character_path(assigns(:content))) }
  end

  describe 'GET #edit' do
    before { get :edit, id: character.id }
    it { is_expected.to respond_with(200) }
    it { is_expected.to render_template('characters/edit') }
  end

  describe 'PUT #update' do
    before do
      put :update, id: character.id, character: {
          age: character.age,
          name: character.name,
          universe: character.universe
        }
    end
    it { is_expected.to redirect_to(character_path(character)) }
  end

  describe 'DELETE #destroy' do
    before { delete :destroy, id: character.id }
    it { is_expected.to redirect_to(characters_url) }

    describe 'the destroyed character' do
      subject { Character.find_by_id(character.id) }
      it { is_expected.to be_nil }
    end
  end
end
