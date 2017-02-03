require 'rails_helper'
require 'support/devise'

RSpec.describe AdminController, type: :controller do
  describe 'logged in user' do
    before do
      user = create(:user)
      sign_in user
    end

    describe 'GET #dashboard' do
      before { get :dashboard }
      it { is_expected.to respond_with(200) }
    end

    describe 'GET #universes' do
      before { get :universes }
      it { is_expected.to respond_with(200) }
    end

    describe 'GET #characters' do
      before { get :characters }
      it { is_expected.to respond_with(200) }
    end

    describe 'GET #locations' do
      before { get :locations }
      it { is_expected.to respond_with(200) }
    end

    describe 'GET #items' do
      before { get :items }
      it { is_expected.to respond_with(200) }
    end
  end

  describe 'logged out user' do
    describe 'GET #dashboard' do
      before { get :dashboard }
      it { is_expected.to respond_with(302) }
    end

    describe 'GET #universes' do
      before { get :universes }
      it { is_expected.to respond_with(302) }
    end

    describe 'GET #characters' do
      before { get :characters }
      it { is_expected.to respond_with(302) }
    end

    describe 'GET #locations' do
      before { get :locations }
      it { is_expected.to respond_with(302) }
    end

    describe 'GET #items' do
      before { get :items }
      it { is_expected.to respond_with(302) }
    end
  end
end
