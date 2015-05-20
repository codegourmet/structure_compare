# TODO: doc (interface, assertions, ...)
module StructureCompare
  class StructuresNotEqualError < RuntimeError; end
  class ArgumentError < ArgumentError; end
end

require 'structure_compare/version'
require 'structure_compare/structure_comparison'
