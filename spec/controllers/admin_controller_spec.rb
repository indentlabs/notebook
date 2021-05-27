# require 'rails_helper'
# require 'support/devise'

# RSpec.describe AdminController, type: :controller do
#   describe 'admin user' do
#     before do
#       user = create(:user)
#       user.update(site_administrator: true)
#       sign_in user
#     end

#     describe 'GET #dashboard' do
#       before { get :dashboard }
#       it { is_expected.to respond_with(200) }
#     end
#   end

#   describe 'non-admin user' do
#     before do
#       user = create(:user)
#       sign_in user
#     end

#     describe 'GET #dashboard' do
#       before { get :dashboard }
#       it { is_expected.to respond_with(302) }
#     end
#   end

#   describe 'logged out user' do
#     describe 'GET #dashboard' do
#       before { get :dashboard }
#       it { is_expected.to respond_with(302) }
#     end
#   end
# end
