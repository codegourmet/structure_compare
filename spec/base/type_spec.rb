require_relative '../spec_helper'

context 'leaf type comparison' do
  context "with hashes" do
    subject(:hash_with_ints) { { a: 1, b: 2 } }

    it { is_expected.to struct_eq(hash_with_ints) }

    context "when comparing int vs float" do
      hash_with_float = { a: 1, b: 2.0 }
      it { is_expected.not_to struct_eq(hash_with_float) }
    end

    context "when comparing int vs string" do
      hash_with_string = { a: 1, b: 'a' }
      it { is_expected.not_to struct_eq(hash_with_string) }
    end
  end

  context "with arrays" do
    subject(:array_with_strings) { %w(a b) }

    it { is_expected.to struct_eq(array_with_strings) }

    context "when comparing string vs int" do
      array_with_int = ['a', 1]
      it { is_expected.not_to struct_eq(array_with_int) }
    end
  end
end
