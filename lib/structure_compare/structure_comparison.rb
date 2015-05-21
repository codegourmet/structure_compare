module StructureCompare
  # TODO: Enumerable to support non-array enumerables
  class StructureComparison
    def initialize(options = {})
      @options = {
        strict_key_order: false,
        check_values: false,
        indifferent_access: false,
        float_tolerance_factor: 0
      }.merge(options)
    end

    # TODO doc
    def structures_are_equal?(expected, actual)
      @path = []
      @error = nil

      begin
        check_structures_equal!(expected, actual)
      rescue StructuresNotEqualError => _error
        return false
      end

      return true
    end

    # TODO doc
    def error
      "root#{@path.join} : #{@error}"
    end

    protected

    def check_structures_equal!(expected, actual)
      check_kind_of!(expected, actual)

      case expected
      when Array
        check_arrays_equal!(expected, actual)
      when Hash
        check_hashes_equal!(expected, actual)
      else
        check_leafs_equal!(expected, actual)
      end
    end

    def check_arrays_equal!(expected, actual)
      check_values_equal!(
        expected.count, actual.count, "array length: #{expected.count} != #{actual.count}"
      )

      expected.each_with_index do |expected_value, index|
        path_segment = "[#{index}]"
        @path.push(path_segment)

        check_structures_equal!(expected_value, actual[index])
        @path.pop
      end
    end

    def check_hashes_equal!(expected, actual)
      check_hash_keys_equal!(expected, actual)

      expected.each do |key, expected_value|
        if @options[:indifferent_access]
          actual_value = with_indifferent_access!(actual, key)
        else
          actual_value = actual[key]
        end

        path_segment = key.is_a?(Symbol) ? "[:#{key}]" : "[\"#{key}\"]"
        @path.push(path_segment)

        check_structures_equal!(expected_value, actual_value)
        @path.pop
      end
    end

    # TODO safeguard in case there's a key as symbol _and_ hash
    def check_hash_keys_equal!(expected, actual)
      expected_keys = expected.keys
      actual_keys = actual.keys

      if @options[:indifferent_access]
        # NOTE: not all hash keys are symbols/strings, only convert symbols
        expected_keys.map! { |key| key.is_a?(Symbol) ? key.to_s : key }
        actual_keys.map! { |key| key.is_a?(Symbol) ? key.to_s : key }
      end

      failure_message = "hash keys aren't equal"

      if @options[:strict_key_order]
        if expected_keys != actual_keys
          not_equal_error!(expected_keys, actual_keys, failure_message)
        end
      else
        # NOTE: first did this with sorting, but can't sort mixed type keys
        all_keys_present = (
          expected_keys.all?{ |key| actual.has_key?(key) } &&
          actual_keys.all?{ |key| expected.has_key?(key) }
        )
        if !all_keys_present
          not_equal_error!(expected_keys, actual_keys, failure_message)
        end
      end
    end

    def check_leafs_equal!(expected, actual)
      check_values_equal!(expected, actual) if @options[:check_values]
    end

    def check_kind_of!(expected, actual)
      unless actual.kind_of?(expected.class)
        failure_message = "expected #{actual.class.to_s} to be kind of #{expected.class.to_s}"
        not_equal_error!(expected, actual, failure_message)
      end
    end

    def check_values_equal!(expected, actual, failure_message = nil)
      if expected.is_a?(Float) && actual.is_a?(Float)
        is_equal = float_equal_with_tolerance_factor?(
          expected, actual, @options[:float_tolerance_factor]
        )
      else
        is_equal = (expected == actual)
      end

      if !is_equal
        failure_message ||= "expected: #{expected.inspect}, got: #{actual.inspect}"
        not_equal_error!(expected, actual, failure_message)
      end
    end

    def float_equal_with_tolerance_factor?(expected, actual, tolerance_factor)
      raise StructureCompare::ArgumentError.new("tolerance_factor must be > 0") if tolerance_factor < 0

      lower_bound = (expected * (1.0 - tolerance_factor) - Float::EPSILON)
      upper_bound = (expected * (1.0 + tolerance_factor) + Float::EPSILON)

      return (lower_bound <= actual) && (actual <= upper_bound)
    end

    # TODO make this part of an overridden exception?
    def not_equal_error!(expected, actual, failure_message)
      @error = failure_message
      raise StructuresNotEqualError.new() # TODO error message, path
    end

    def with_indifferent_access!(actual, key)
      if [Symbol, String].include?(key.class)
        has_both_types = (actual.has_key?(key) && actual.has_key?(key.to_s))
        duplicate_key_error!(key) if has_both_types

        actual.has_key?(key.to_s) ? actual[key.to_s] : actual[key.to_sym]
      else
        actual[key]
      end
    end

    def duplicate_key_error!(key)
      raise StructureCompare::IndifferentAccessError.new(
        "#{@path.join}: key is present as string and symbol. " \
        "can not use indifferent_access option!"
      )
    end
  end
end
