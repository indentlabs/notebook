# require 'rails_helper'
# require 'support/devise'

# RSpec.describe CharactersGeneratorController, type: :controller do
#   describe 'GET #age' do
#     before { get :age }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:lower_limit)' do
#       subject { assigns(:lower_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be <= assigns(:upper_limit) }
#     end

#     describe 'assigns(:upper_limit)' do
#       subject { assigns(:upper_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= assigns(:lower_limit) }
#     end
#   end

#   describe 'GET #bodytype' do
#     before { get :bodytype }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_types)' do
#       subject { assigns(:possible_types) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #eyecolor' do
#     before { get :eyecolor }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_colors)' do
#       subject { assigns(:possible_colors) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #facialhair' do
#     before { get :facialhair }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_types)' do
#       subject { assigns(:possible_styles) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #haircolor' do
#     before { get :haircolor }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_colors)' do
#       subject { assigns(:possible_colors) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #hairstyle' do
#     before { get :hairstyle }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_styles)' do
#       subject { assigns(:possible_styles) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #height' do
#     before { get :height }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:lower_foot_limit)' do
#       subject { assigns(:lower_foot_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= 0 }
#       it { is_expected.to be <= assigns(:upper_foot_limit) }
#     end

#     describe 'assigns(:upper_foot_limit)' do
#       subject { assigns(:upper_foot_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= 0 }
#       it { is_expected.to be >= assigns(:lower_foot_limit) }
#     end

#     describe 'assigns(:lower_inch_limit)' do
#       subject { assigns(:lower_inch_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= 0 }
#       it { is_expected.to be <= assigns(:upper_inch_limit) }
#     end

#     describe 'assigns(:upper_inch_limit)' do
#       subject { assigns(:upper_inch_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= 0 }
#       it { is_expected.to be >= assigns(:lower_inch_limit) }
#     end
#   end

#   describe 'GET #identifyingmark' do
#     before { get :identifyingmark }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_marks)' do
#       subject { assigns(:possible_marks) }
#       it { is_expected.to_not be_nil }
#     end

#     describe 'assigns(:possible_locations)' do
#       subject { assigns(:possible_locations) }
#       it { is_expected.to_not be_nil }
#     end
#   end

#   describe 'GET #name' do
#     before { get :name }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:male_first_names)' do
#       subject { assigns(:male_first_names) }
#       it { is_expected.to_not be_empty }
#     end

#     describe 'assigns(:female_first_names)' do
#       subject { assigns(:female_first_names) }
#       it { is_expected.to_not be_empty }
#     end

#     describe 'assigns(:last_names)' do
#       subject { assigns(:last_names) }
#       it { is_expected.to_not be_empty }
#     end

#     describe 'assigns(:all_first_names)' do
#       subject { assigns(:all_first_names) }
#       it { is_expected.to_not be_empty }
#     end

#     describe 'assigns(:all_last_names)' do
#       subject { assigns(:all_last_names) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #race' do
#     before { get :race }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:possible_races)' do
#       subject { assigns(:possible_races) }
#       it { is_expected.to_not be_empty }
#     end
#   end

#   describe 'GET #skintone' do
#     before { get :bodytype }
#     it { is_expected.to respond_with(200) }
#   end

#   describe 'GET #weight' do
#     before { get :weight }
#     it { is_expected.to respond_with(200) }

#     describe 'assigns(:lower_limit)' do
#       subject { assigns(:lower_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be > 0 }
#       it { is_expected.to be <= assigns(:upper_limit) }
#     end

#     describe 'assigns(:upper_limit)' do
#       subject { assigns(:upper_limit) }
#       it { is_expected.to be_an(Integer) }
#       it { is_expected.to be >= assigns(:lower_limit) }
#     end
#   end
# end
