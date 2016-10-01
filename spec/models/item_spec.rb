require 'rails_helper'

RSpec.describe Item, type: :model do
  context 'when name is nil' do
    subject { build(:item, name: nil) }
    it { is_expected.to_not be_valid }
  end
end
