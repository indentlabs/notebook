require 'rails_helper'

shared_examples_for 'a generator' do | types |
  it { is_expected.to respond_with(200) }

  describe "assigns #{types}" do
    it { assigns(types) }
  end
end
