require_relative '../spec_helper'

context 'arrays' do
  subject(:simple_array) { [1, 2, 3] }

  context 'when equal' do
    it { is_expected.to struct_eq(simple_array) }
  end

  context 'when not equal' do
    it { is_expected.not_to struct_eq(['another array']) }
  end
end
