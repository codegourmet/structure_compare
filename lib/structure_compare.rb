# TODO rename to structure_compare
# TODO Enumerable to support non-array enumerables
# TODO doc
module StructureCompare

  class StructuresNotEqualError < RuntimeError; end

  def self.structures_are_equal?(expected, actual, options = {})
    options = { # TODO doc
      strict_key_order: false # ,
      # check_values: false
      # values_tolerance: 0
    }.merge(options)

    begin
      check_structures_equal!(expected, actual, options)
    rescue StructuresNotEqualError => _error
      return false
    end

    return true
  end

  protected

    def self.check_structures_equal!(expected, actual, options)
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
      check_equal!(expected.count, actual.count)

      expected.each_with_index do |expected_value, index|
        check_structures_equal!(expected_value, actual[index], options)
      end
    end

    def self.check_hashes_equal!(expected, actual, options)
      if options[:strict_key_order]
        check_equal!(expected.keys, actual.keys)
      else
        check_equal!(expected.keys.sort, actual.keys.sort)
      end

      expected.each do |expected_key, expected_value|
        check_structures_equal!(expected_value, actual[expected_key], options)
      end
    end

    def self.check_leafs_equal!(expected, actual, options)
      return # TODO compare values if flag. compare values with tolerance if setting
    end

    def self.check_kind_of!(expected, actual)
      unless actual.kind_of?(expected.class)
        not_equal_error!(expected, actual)
      end
    end

    def self.check_equal!(expected, actual)
      if actual != expected
        not_equal_error!(expected, actual)
      end
    end

    # TODO make this part of an overridden exception?
    def self.not_equal_error!(expected, actual)
      raise StructuresNotEqualError.new() # TODO error message, path
    end

end

# TODO test if monkeypatching MiniTest::Assertions works

require 'version'
