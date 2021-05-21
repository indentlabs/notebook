# require 'rails_helper'
# require 'support/devise'
# include Rails.application.routes.url_helpers

# shared_examples_for 'a controller for a content item' do
#   before(:all) do
#     @model_class = described_class.controller_name.classify.constantize
#     @model_name = described_class.controller_name.classify.constantize.model_name.param_key
#   end

#   before(:each) do
#     @request.env['devise.mapping'] = Devise.mappings[:user]
#     @user = create(:user)

#     sign_in @user
#   end

#   let(:model) { create(@model_name.to_sym, user: @user) }

#   describe 'GET #index' do
#     before { get :index }
#     it { is_expected.to respond_with(200) }
#     it { is_expected.to render_template('content/index') }

#     describe 'assigns(:content)' do
#       subject { assigns(:content) }
#       it { is_expected.to_not be_nil }
#     end
#   end

#   describe 'GET #new' do
#     before { get :new }
#     it { is_expected.to respond_with(200) }
#     it { is_expected.to render_template(locals: "#{@model_name.pluralize}/new", layout: :application) }
#   end

#   describe 'POST #create' do
#     # todo change this to use custom attributes now
#     # before do
#     #   post :create, params: { @model_name => {
#     #     name: model.name,
#     #     user: @user
#     #   } }
#     # end
#     # it { is_expected.to redirect_to(polymorphic_path(assigns(:content))) }
#   end

#   describe 'GET #edit' do
#     before { get :edit, params: { id: model.id } }
#     it { is_expected.to respond_with(200) }
#     it { is_expected.to render_template(locals: "#{@model_name.pluralize}/edit", layout: :application) }
#   end

#   describe 'PUT #update' do
#     # todo change this to use custom attributes now
#     # before do
#     #   put :update, params: { id: model.id, @model_name => {
#     #     name: model.name,
#     #     user: @user
#     #   } }
#     # end
#     # it { is_expected.to redirect_to(polymorphic_path(model)) }
#   end

#   describe 'DELETE #destroy' do
#     before { delete :destroy, params: { id: model.id } }
#     it { is_expected.to redirect_to(polymorphic_path(@model_class)) }

#     describe 'the destroyed model' do
#       subject { @model_class.find_by_id(model.id) }
#       it { is_expected.to be_nil }
#     end
#   end
# end
