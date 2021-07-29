# require 'rails_helper'
# require 'support/devise'

# RSpec.describe LocationsGeneratorController, type: :controller do
#   describe 'GET #name' do
#     before { get :name }

#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:root_name)' do
#       subject { assigns(:root_name) }
#       it { is_expected.to_not be_blank }
#     end

#     describe 'assigns(:prefix_occurrence)' do
#       subject { assigns(:prefix_occurrence) }
#       it { is_expected.to_not be_blank }
#       it { is_expected.to be_between(0, 1).inclusive }
#     end

#     describe 'assigns(:postfix_occurrence)' do
#       subject { assigns(:postfix_occurrence) }
#       it { is_expected.to_not be_blank }
#       it { is_expected.to be_between(0, 1).inclusive }
#     end

#     describe 'assigns(:syllables_upper_limit)' do
#       subject { assigns(:syllables_upper_limit) }
#       it { is_expected.to_not be_blank }
#       it { is_expected.to be >= assigns(:syllables_lower_limit) }
#     end

#     describe 'assigns(:syllables_lower_limit)' do
#       subject { assigns(:syllables_lower_limit) }
#       it { is_expected.to_not be_blank }
#       it { is_expected.to be >= 0 }
#       it { is_expected.to be <= assigns(:syllables_upper_limit) }
#     end

#     describe 'assigns(:prefixes)' do
#       subject { assigns(:prefixes) }
#       it { is_expected.to_not be_blank }
#     end

#     describe 'assigns(:postfixes)' do
#       subject { assigns(:postfixes) }
#       it { is_expected.to_not be_blank }
#     end

#     describe 'assigns(:syllables)' do
#       subject { assigns(:syllables) }
#       it { is_expected.to_not be_blank }
#     end
#   end
# end
