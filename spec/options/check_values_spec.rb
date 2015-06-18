require_relative '../spec_helper'

context 'with option check_values' do
  subject { { a: 1, b: 2 } }
  let(:simple_hash_different_values) { { a: 1, b: 3 } }

  context 'when defaulted' do
    it { is_expected.not_to struct_eq(simple_hash_different_values) }
  end

  context 'when enabled' do
    it { is_expected.not_to struct_eq(simple_hash_different_values, check_values: true) }
  end

  context 'when disabled' do
    it { is_expected.to struct_eq(simple_hash_different_values, check_values: false) }
  end

  context 'when strict_key_order disabled' do
    # this was a bug where relaxed hash key order would result in wrong values being compared
    subject { { a: 1, b: 2 } }
    let(:reverse_simple_hash) { { b: 2, a: 1 } }
    it { is_expected.to struct_eq(reverse_simple_hash, check_values: true, strict_key_order: false) }
  end
end
