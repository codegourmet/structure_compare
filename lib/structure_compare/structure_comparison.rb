module StructureCompare
  # TODO: Enumerable to support non-array enumerables
  class StructureComparison
    def initialize(options = {})
      @options = {
        strict_key_order: false,
        check_values: false,
        treat_hash_symbols_as_strings: false,
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
      "#{@path.join} : #{@error}"
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
      check_equal!(
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

      expected_values = expected.values
      actual_values = actual.values

      expected_values.each_with_index do |expected_value, index|
        key = expected.keys[index]
        path_segment = key.is_a?(Symbol) ? "[:#{key}]" : "[\"#{key}\"]"
        @path.push(path_segment)

        check_structures_equal!(expected_value, actual_values[index])
        @path.pop
      end
    end

    def check_hash_keys_equal!(expected, actual)
      expected_keys = expected.keys
      actual_keys = actual.keys

      if @options[:treat_hash_symbols_as_strings]
        # NOTE: not all hash keys are symbols/strings, only convert symbols
        expected_keys.map! { |key| key.is_a?(Symbol) ? key.to_s : key }
        actual_keys.map! { |key| key.is_a?(Symbol) ? key.to_s : key }
      end

      if @options[:strict_key_order]
        check_equal!(expected_keys, actual_keys)
      else
        begin
          expected_keys.sort!
          actual_keys.sort!
        rescue ::ArgumentError => error
          raise StructureCompare::ArgumentError.new(
            "Unable to sort hash keys: \"#{error}\"." +
            'Try enabling :strict_key_order option to prevent sorting of mixed-type hash keys.'
          )
        end

        check_equal!(expected_keys, actual_keys)
      end
    end

    def check_leafs_equal!(expected, actual)
      check_equal!(expected, actual) if @options[:check_values]
    end

    def check_kind_of!(expected, actual)
      unless actual.kind_of?(expected.class)
        failure_message = "expected #{actual.class.to_s} to be kind of #{expected.class.to_s}"
        not_equal_error!(expected, actual, failure_message)
      end
    end

    def check_equal!(expected, actual, failure_message = nil)
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
  end
end
