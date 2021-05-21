# describe 'app/views/cards/serendipitous/_content_question.html.erb' do

#   let(:question) { 'What is my name?' }
#   let(:field) { :name }
#   let(:question_object) { { field: field, question: question } }
#   let(:content) { create(:character) }

#   shared_examples_for 'an empty serendipitous card' do
#     it 'renders nothing' do
#       render partial: 'cards/serendipitous/content_question', locals: { question: question_object, content: content }
#       expect(response).to match(/decided not to render serendipitous card/)
#     end
#   end

#   # todo update these test with the new serendipitous logic
#   # context 'when question is an empty string' do
#   #   let(:question_object) { '' }
#   #   it_behaves_like 'an empty serendipitous card'
#   # end
#   #
#   # context 'when question[:field] is an empty string' do
#   #   let(:question_object) { { field: '', question: question } }
#   #   it_behaves_like 'an empty serendipitous card'
#   # end
#   #
#   # context 'when question[:question] is an empty string' do
#   #   let(:question_object) { { field: field, question: '' } }
#   #   it_behaves_like 'an empty serendipitous card'
#   # end
#   #
#   # context 'when content is an empty string' do
#   #   let(:content) { '' }
#   #   it_behaves_like 'an empty serendipitous card'
#   # end
# end
