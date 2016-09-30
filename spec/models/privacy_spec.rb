require 'rails_helper'

shared_examples_for 'content with privacy' do
  context 'model is public' do
    let(:model) { build(:character, name: 'Ellen', privacy: 'public')}

    describe '.public_content?' do
      subject { model.public_content? }
      it { is_expected.to be true }
    end
  end
end

RSpec.describe Character, type: :model do
  it_behaves_like 'content with privacy'
end
