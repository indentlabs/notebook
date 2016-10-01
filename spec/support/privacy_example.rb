require 'rails_helper'

shared_examples_for 'content with privacy' do
  context 'model is public' do
    let(:model) {
      build(
        described_class.model_name.param_key.to_sym,
        privacy: 'public'
      )
    }

    describe '.public_content?' do
      subject { model.public_content? }
      it { is_expected.to be true }
    end
  end
end
