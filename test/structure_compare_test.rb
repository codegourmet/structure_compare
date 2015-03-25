require_relative "test_helper"
require_relative "../lib/structure_compare"

class StructureCompareTest < MiniTest::Test

  def setup
  end

  def test_compares_simple_structures
    assert_structures_equal({a: 1, b: 2}, {a: 1, b: 2})
  end

  def test_compares_keys_of_hashes
    refute_structures_equal({a: 1, b: 2}, {a: 1, other_key: 2})
    refute_structures_equal({a: 1, b: 2}, {a: 1, b: 2, c: 3})
  end

  def test_hash_key_order_is_compared_if_option_set
    assert_structures_equal({a: 1, b: 2}, {b: 2, a: 1})
    assert_structures_equal({a: 1, b: 2}, {b: 2, a: 1}, strict_key_order: false)
    refute_structures_equal({a: 1, b: 2}, {b: 2, a: 1}, strict_key_order: true)
  end

  def test_leaf_values_are_compared_if_option_set
    assert_structures_equal({a: 1, b: 2}, {a: 111, b: 222})
    refute_structures_equal({a: 1, b: 2}, {a: 111, b: 222}, check_values: true)
  end

  def test_compares_leaf_value_types
    refute_structures_equal({a: 1, b: 2}, {a: 1, b: "2"})
    refute_structures_equal({a: 1, b: 2}, {a: 1, b: 2.0})
    refute_structures_equal({a: 1, b: 2}, {a: Time.now, b: 2})
  end

  protected

    def assert_structures_equal(expected, actual, options = {})
      assert StructureCompare.structures_are_equal?(expected, actual, options)
    end

    def refute_structures_equal(expected, actual, options = {})
      refute StructureCompare.structures_are_equal?(expected, actual, options)
    end

end
