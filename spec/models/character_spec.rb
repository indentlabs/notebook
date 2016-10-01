require 'rails_helper'
require 'support/privacy_example'
require 'support/public_scope_example'

RSpec.describe Character, type: :model do
  it_behaves_like 'content with privacy'
  it_behaves_like 'content with an is_public scope'

  context 'when name is nil' do
    subject { build(:character, name: nil) }
    it { is_expected.to_not be_valid }
  end
end
