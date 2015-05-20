require_relative "test_helper"
require_relative '../lib/structure_compare'
require_relative '../lib/structure_compare/minitest'

class StructureCompareTest < MiniTest::Test

  def setup
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

  def test_compares_leaf_value_types
    assert_structures_equal({a: 1, b: 2}, {b: 2, a: 1})
    refute_structures_equal({a: 1, b: 2}, {a: 1, b: 2.0})

    assert_structures_equal(%w(a b c d), %w(a b c d))
    refute_structures_equal(%w(a b c d), ['a', 'b', 'c', 111])
  end

  def test_leaf_values_are_compared_if_option_set
    assert_structures_equal({a: 1, b: 2}, {a: 111, b: 222})
    refute_structures_equal({a: 1, b: 2}, {a: 111, b: 222}, check_values: true)

    assert_structures_equal(%w(a b c d), %w(a b c d))
    refute_structures_equal(%w(a b c d), %w(A b c d), check_values: true)
  end

  def test_compares_arrays
    assert_structures_equal([1, 2, 3], [1, 2, 3])
    refute_structures_equal([1, 2], [1, 2, 3])
  end

  def test_stores_error_with_path_in_getter
    structure_a = { x: 1, a: [{ b: [1, 1, 1] }] }
    structure_b = { x: 1, a: [{ b: [1, 9, 1] }] }

    comparison = StructureCompare::StructureComparison.new(check_values: true)
    comparison.structures_are_equal?(structure_a, structure_b)
    assert_match "[:a][0][:b][1]", comparison.error
  end

  def test_shows_values_for_expected_and_actual_if_error
    structure_a = { x: 1, a: [{ b: [1, "FOO", 1] }] }
    structure_b = { x: 1, a: [{ b: [1, "BAR", 1] }] }

    assert_structures_equal(structure_a, structure_b)
    comparison = StructureCompare::StructureComparison.new(check_values: true)
    comparison.structures_are_equal?(structure_a, structure_b)
    assert_match "FOO", comparison.error
    assert_match "BAR", comparison.error
  end

  def test_compares_deep_structures
    structure_a = { x: 1, a: [{ b: [1, 1, 1] }] }
    structure_b = { x: 1, a: [{ b: [1, 9, 1] }] }

    assert_structures_equal(structure_a, structure_a, check_values: true)
    refute_structures_equal(structure_a, structure_b, check_values: true)
  end

  def test_mixed_type_hash_keys_trigger_error_unless_strict_order_set
    hash = { a: 1, 5 => 6 }

    assert_raises StructureCompare::ArgumentError do
      assert_structures_equal(hash, hash)
    end

    assert_structures_equal(hash, hash, strict_key_order: true)
  end

  def test_symbol_keys_are_strings_if_option_set
    string_hash = {"a" => 1, "b" => 2, 5 => 6}
    symbol_hash = {a: 1, b: 2, 5 => 6}

    refute_structures_equal(string_hash, symbol_hash, strict_key_order: true)
    assert_structures_equal(
      string_hash, symbol_hash,
      treat_hash_symbols_as_strings: true, strict_key_order: true
    )
  end

  def test_compares_floats_correctly
    assert_structures_equal([1.0, 2.0, 3.0], [1.0, 2.0, 3.0], check_values: true)
    assert_structures_equal(
      [1.0 - Float::EPSILON * 0.5, 2.0 + Float::EPSILON * 0.5, 3.0],
      [1.0, 2.0, 3.0],
      check_values: true
    )

    refute_structures_equal(
      [1.0 - Float::EPSILON * 2, 2.0, 3.0],
      [1.0, 2.0, 3.0],
      check_values: true
    )

    refute_structures_equal(
      [1.0 + Float::EPSILON * 2, 2.0, 3.0],
      [1.0, 2.0, 3.0],
      check_values: true
    )
  end

  def test_compares_with_tolerance_if_options_set
    assert_structures_equal(%w(a b c d), %w(a b c d), {
      # just to catch bugs with this option concerning non-floats
      check_values: true, float_tolerance_factor: 0.1
    })

    refute_structures_equal([1.0, 2.0, 3.0], [1.0001, 2.0001, 3.0001], {
      check_values: true
    })

    assert_structures_equal([1.0, 2.0, 3.0], [1.0001, 2.0001, 3.0001], {
      check_values: true, float_tolerance_factor: 0.1
    })
    assert_structures_equal([1.0, 2.0, 3.0], [1.1, 2.1, 3.1], {
      check_values: true, float_tolerance_factor: 0.1
    })
    assert_structures_equal([1.0, 2.0, 3.0], [0.9, 1.9, 2.9], {
      check_values: true, float_tolerance_factor: 0.1
    })

    assert_structures_equal(
      [1.0, 2.0, 3.0],
      [0.9 - Float::EPSILON * 0.5, 2.1, 3.1],
      { check_values: true, float_tolerance_factor: 0.1 }
    )
    refute_structures_equal(
      [1.0, 2.0, 3.0],
      [0.9 - Float::EPSILON * 2, 2.1, 3.1],
      { check_values: true, float_tolerance_factor: 0.1 }
    )

    assert_structures_equal(
      [1.0, 2.0, 3.0],
      [1.1 + Float::EPSILON * 0.5, 2.1, 3.1],
      { check_values: true, float_tolerance_factor: 0.1 }
    )
    refute_structures_equal(
      [1.0, 2.0, 3.0],
      [1.1 + Float::EPSILON * 2, 2.1, 3.1],
      { check_values: true, float_tolerance_factor: 0.1 }
    )
  end

  def test_ensures_tolerance_factor_is_gt_0
    assert_raises StructureCompare::ArgumentError do
      assert_structures_equal(
        [1.0], [1.0], check_values: true, float_tolerance_factor: -0.1
      )
    end
  end
end
