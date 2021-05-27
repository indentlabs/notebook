# require 'rails_helper'

# describe HasAttributes do
#   let(:user) { create(:user) }
#   let(:category) { create(:attribute_category, entity_type: 'universe', user: user) }
#   let(:field) { create(:attribute_field, attribute_category: category, user: user, name: 'foo') }

#   describe '.attribute_categories' do
#     let(:categories) { Universe.attribute_categories(user) }

#     context 'without a user' do
#       let(:user) { nil }

#       it 'returns an array of AttributeCategory' do
#         expect(categories).to be_a_kind_of(Array)
#         expect(categories.first).to be_a_kind_of(AttributeCategory)
#       end
#     end

#     context 'with a user' do
#       it 'returns an array of AttributeCategory' do
#         expect(categories).to be_a_kind_of(ActiveRecord::AssociationRelation)
#         expect(categories.first).to be_a_kind_of(AttributeCategory)
#       end

#       context 'with custom attributes' do
#         before { field }

#         it 'includes custom attribute categories' do
#           expect(categories).to include(category)
#         end
#       end
#     end
#   end

#   describe '#update_custom_attributes' do
#     subject { create(:universe, user: user) }
#     let(:values) { [{ name: field.name }] }

#     before do
#       subject.custom_attribute_values = values
#     end

#     context 'with attached custom attribute values' do
#       it 'saves attribute field values' do
#         expect {
#           subject.save
#         }.to change{Attribute.count}.from(0).to(1)
#       end
#     end
#   end
# end
