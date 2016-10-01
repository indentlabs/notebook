require 'rails_helper'

RSpec.describe Item, type: :model do
  it_behaves_like 'content with privacy'
  it_behaves_like 'content with an is_public scope'

  context 'when name is nil' do
    subject { build(:item, name: nil) }
    it { is_expected.to_not be_valid }
  end
end
