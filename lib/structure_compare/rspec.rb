module StructureCompare
  # custom rspec matchers for StructureCompare
  module RSpecMatchers
    # basic matcher class
    class StructureCompareMatcher
      def initialize(expected, options = {})
        @expected = expected
        @options = options
      end

      def matches?(actual)
        @actual = actual

        comparison = StructureCompare::StructureComparison.new(@options)
        is_equal = comparison.structures_are_equal?(@expected, actual)
        @error = comparison.error

        is_equal
      end

      def description
        "consider structures as equal"
      end

      def failure_message
        "expected structures to match, but found difference: \n    #{@error}"
      end

      def failure_message_when_negated
        'expected structures to not match, but were considered equal'
      end
    end

    def struct_eq(expected, options = {})
      StructureCompareMatcher.new(expected, options)
    end
  end
end
