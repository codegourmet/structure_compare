require_relative '../spec_helper'

describe 'hash comparison' do
  subject(:simple_hash) { { a: 1, b: 2 } }

  context 'when hash keys are equal' do
    it { is_expected.to struct_eq(simple_hash) }
  end

  context 'when all hash keys are different' do
    it { is_expected.not_to struct_eq(other_key_1: 1, other_key_2: 2) }
  end

  context 'when one hash key is different' do
    specify { expect(a: 1, b: 2).not_to struct_eq(a: 1, other_key: 2) }
  end
end
