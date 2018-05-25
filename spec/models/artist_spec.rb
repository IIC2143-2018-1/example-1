require 'rails_helper'

RSpec.describe Artist, type: :model do
  it { is_expected.to have_many(:albums).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

  describe "#uppercase_name" do
    context 'with one letter' do
      before do
        @a = described_class.new(name: 'a')
      end

      it { expect(@a.uppercase_name).to eq('A')}
    end

    context 'with lowercase name' do
      before do
        @a = described_class.new(name: 'queen')
      end

      it { expect(@a.uppercase_name).to eq('QUEEN')}
    end

    context 'with uppercase name' do
      before do
        @a = described_class.new(name: 'QUEEN')
      end

      it { expect(@a.uppercase_name).to eq('QUEEN')}
    end
  end
end
