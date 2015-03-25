# TODO rename to structure_compare
# TODO Enumerable to support non-array enumerables
# TODO doc
module StructureCompare

  class StructuresNotEqualError < RuntimeError; end

  def self.structures_are_equal?(expected, actual, options = {})
    begin
      check_structures_equal!(expected, actual, options)
    rescue StructuresNotEqualError => _error
      return false
    end

    return true
  end

  protected

    def self.check_structures_equal!(expected, actual, options)
      options = { # TODO doc
        strict_key_order: false,
        check_values: false,
        float_tolerance_factor: 0
      }.merge(options)

      check_kind_of!(expected, actual)

      case expected
      when Array
        check_arrays_equal!(expected, actual, options)
      when Hash
        check_hashes_equal!(expected, actual, options)
      else
        check_leafs_equal!(expected, actual, options)
      end
    end

    def self.check_arrays_equal!(expected, actual, options)
      check_equal!(expected.count, actual.count, options)

      expected.each_with_index do |expected_value, index|
        check_structures_equal!(expected_value, actual[index], options)
      end
    end

    def self.check_hashes_equal!(expected, actual, options)
      if options[:strict_key_order]
        check_equal!(expected.keys, actual.keys, options)
      else
        check_equal!(expected.keys.sort, actual.keys.sort, options)
      end

      expected.each do |expected_key, expected_value|
        check_structures_equal!(expected_value, actual[expected_key], options)
      end
    end

    def self.check_leafs_equal!(expected, actual, options)
      check_equal!(expected, actual, options) if options[:check_values]
    end

    def self.check_kind_of!(expected, actual)
      unless actual.kind_of?(expected.class)
        not_equal_error!(expected, actual)
      end
    end

    def self.check_equal!(expected, actual, options)
      if expected.is_a?(Float) && actual.is_a?(Float)
        is_equal = float_equal_with_tolerance_factor?(
          expected, actual, options[:float_tolerance_factor]
        )
      else
        is_equal = (expected == actual)
      end

      not_equal_error!(expected, actual) if !is_equal
    end

    def self.float_equal_with_tolerance_factor?(expected, actual, tolerance_factor)
      raise ArgumentError.new("tolerance_factor must be > 0") if tolerance_factor < 0

      lower_bound = (expected * (1.0 - tolerance_factor) - Float::EPSILON)
      upper_bound = (expected * (1.0 + tolerance_factor) + Float::EPSILON)

      return (lower_bound <= actual) && (actual <= upper_bound)
    end

    # TODO make this part of an overridden exception?
    def self.not_equal_error!(expected, actual)
      raise StructuresNotEqualError.new() # TODO error message, path
    end

end

# TODO test if monkeypatching MiniTest::Assertions works

require 'version'
