require_relative '../spec_helper'

describe 'deep structures' do
  subject(:deep_structure)     { { x: 1, a: [{ b: [1] }] } }
  let(:other_deep_structure) { { x: 1, a: [{ c: [1] }] } }

  context 'when equal' do
    it { is_expected.to struct_eq(deep_structure) }
  end

  context 'when not equal' do
    it { is_expected.not_to struct_eq(other_deep_structure) }
  end

end
