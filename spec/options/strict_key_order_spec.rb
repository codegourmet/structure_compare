require_relative '../spec_helper'

context 'with option strict_key_order' do
  subject { { a: 1, b: 2 } }
  let(:reverse_simple_hash) { { b: 2, a: 1 } }

  context 'when defaulted' do
    it { is_expected.to struct_eq(reverse_simple_hash) }
  end

  context 'when enabled' do
    it { is_expected.not_to struct_eq(reverse_simple_hash, strict_key_order: true) }
  end

  context 'when disabled' do
    it { is_expected.to struct_eq(reverse_simple_hash, strict_key_order: false) }

    it 'does not break indifferent_access option' do
      # this was a bug with combining relaxed key order and indifferent access
      expect(a: 1, b: 2).to struct_eq(
        { 'a' => 1, 'b' => 2 },
        strict_key_order: false, indifferent_access: true
      )
    end
  end

  context 'when presented with mixed key types' do
    # this was a bug where we compared keys by sorting them, resulting in
    # an ArgumentError if keys weren't comparable (String vs. Fixnum)
    subject(:mixed_hash) { { a: 1, 5 => 6 } }
    it { is_expected.to struct_eq(mixed_hash) }
  end
end
