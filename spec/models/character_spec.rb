require 'rails_helper'

RSpec.describe Character, type: :model do
  context 'when name is nil' do
    subject { build(:character, name: nil) }
    it { is_expected.to_not be_valid }
  end

  context 'when character is in a public universe' do
    let(:universe) { create(:universe, privacy: 'public') }

    context 'when character is private' do
      let(:character) { create(:character, universe: universe, privacy: 'private') }

      describe 'Character.is_public' do
        subject { Character.is_public }
        it { is_expected.to include(character) }
      end
    end

    context 'when character is public' do
      let(:character) { create(:character, universe: universe, privacy: 'public') }

      describe 'Character.is_public' do
        subject { Character.is_public }
        it { is_expected.to include(character) }
      end
    end
  end

  context 'when character is in a private universe' do
    let(:universe) { create(:universe, privacy: 'private') }

    context 'when character is private' do
      let(:character) { create(:character, universe: universe, privacy: 'private') }

      describe 'Character.is_public' do
        subject { Character.is_public }
        it { is_expected.to_not include(character) }
      end
    end

    context 'when character is public' do
      let(:character) { create(:character, universe: universe, privacy: 'public') }

      describe 'Character.is_public' do
        subject { Character.is_public }
        it { is_expected.to include(character) }
      end
    end
  end
end
