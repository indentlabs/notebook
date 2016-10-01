require 'rails_helper'

shared_examples_for 'content that validates presence of name' do
  let(:model) {
    build(
      described_class.model_name.param_key.to_sym,
      name: nil
    )
  }


  it { is_expected.to_not be_valid }
end
