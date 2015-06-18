require_relative '../spec_helper'

context 'with option indifferent_access' do
  subject { { "a" => 1, "b" => 2, 5 => 6 } }
  let(:symbol_hash) { { a: 1, b: 2, 5 => 6 } }

  context 'when defaulted' do
    it { is_expected.not_to struct_eq(symbol_hash) }
  end

  context 'when enabled' do
    it { is_expected.to struct_eq(symbol_hash, indifferent_access: true) }
  end

  context 'when disabled' do
    it { is_expected.not_to struct_eq(symbol_hash, indifferent_access: false) }
  end

  context 'with symbol and string key present' do
    subject { { 'a' => 1, a: 2 } }

    it 'raises an exception' do
      expect do
        comparison = StructureCompare::StructureComparison.new(indifferent_access: true)
        comparison.structures_are_equal?(subject, subject)
      end.to raise_exception(StructureCompare::IndifferentAccessError)
    end
  end

  context 'with same type keys' do
    # this was a bug where exception was raised even if everything is ok

    context 'with string key' do
      subject { { "a" => 1 } }
      it { is_expected.to struct_eq(subject, indifferent_access: true) }
    end

    context 'with symbol key' do
      subject { { a: 1 } }
      it { is_expected.to struct_eq(subject, indifferent_access: true) }
    end
  end
end
