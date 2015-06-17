require 'structure_compare'
require 'structure_compare/rspec'

RSpec.configure do |config|
  config.include(StructureCompare::RSpecMatchers)
  config.color = true
end
