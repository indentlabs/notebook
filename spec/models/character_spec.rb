# require 'rails_helper'
# require 'support/privacy_example'
# require 'support/public_scope_example'

# RSpec.describe Character, type: :model do
#   it_behaves_like 'content with privacy'
#   it_behaves_like 'content with an is_public scope'

#   context "when character having a sibling is deleted" do
#     before do
#       @alice = create(:character, name: "Alice")
#       @bob = create(:character, name: "Bob")
#       @alice.siblings << @bob
#       @alice.destroy()
#     end

#     it "don't delete the sibling" do
#       expect(Character.exists?(@bob.id)).to be true
#     end

#     it "delete sibling relation" do
#       expect(@alice.siblings.include?(@bob)).to be false
#     end

#     it "delete reverse sibling relation" do
#       expect(@bob.siblings.include?(@alice)).to be false
#     end
#   end
# end
