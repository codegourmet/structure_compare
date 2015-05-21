# TODO: doc (interface, assertions, ...)
module StructureCompare
  class ArgumentError < ::ArgumentError; end
  class RuntimeError < ::RuntimeError; end

  class StructuresNotEqualError < RuntimeError; end
  class IndifferentAccessError < RuntimeError; end
end

require 'structure_compare/version'
require 'structure_compare/structure_comparison'
