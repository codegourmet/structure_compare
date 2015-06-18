require_relative "test_helper"
require_relative '../lib/structure_compare'
require_relative '../lib/structure_compare/minitest'

class StructureCompareTest < MiniTest::Test

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

    assert_structures_equal(structure_a, structure_b, check_values: false)

    comparison = StructureCompare::StructureComparison.new(check_values: true)
    comparison.structures_are_equal?(structure_a, structure_b)
    assert_match "FOO", comparison.error
    assert_match "BAR", comparison.error
  end

  def test_option_for_indifferent_access_raises_if_symbol_and_string_key_present
    hash = { "a" => 1, a: 2 }
    assert_structures_equal(hash, hash, strict_key_order: true)

    assert_raises StructureCompare::IndifferentAccessError do
      assert_structures_equal(
        hash, hash, strict_key_order: true, indifferent_access: true
      )
    end

    # this was a bug where exception was raised even if everything is ok
    hash = { "a" => 1 }
    assert_structures_equal(hash, hash, indifferent_access: true)
    hash = { a: 1 }
    assert_structures_equal(hash, hash, indifferent_access: true)
  end

  def test_indifferent_access_error_triggers_only_when_both_types_present
    string_key_hash = { "a" => 1, "b" => 2 }
    symbol_key_hash = { "a": 1, "b": 2 }

    assert_structures_equal(string_key_hash, symbol_key_hash, indifferent_access: true)
    assert_structures_equal(symbol_key_hash, string_key_hash, indifferent_access: true)
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
