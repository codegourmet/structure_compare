class Minitest::Test

  protected

  def assert_structures_equal(expected, actual, options = {})
    comparison = StructureCompare::StructureComparison.new(options)
    is_equal = comparison.structures_are_equal?(expected, actual)
    assert is_equal, comparison.error
  end

  def refute_structures_equal(expected, actual, options = {})
    comparison = StructureCompare::StructureComparison.new(options)
    is_equal = comparison.structures_are_equal?(expected, actual)
    refute is_equal, "structures are not expected to be equal"
  end
end
