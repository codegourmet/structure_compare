# structure_compare

Compares the structure of two deep nested Ruby structures

## General

Use case: you're writing an API response or a JSON export and want to unit test it.

## Installation

```
gem install structure_compare
```

or add it to your `Gemfile`

### quick-n-dirty example:
```ruby
require 'structure_compare'
comparison = StructureCompare::StructureComparison.new

expected = { a: 1, b: 2, c: [1, 2, 3] }
actual   = { a: 1, b: 2, c: [1, 2, "A"] }

comparison.structures_are_equal?(expected, actual)
puts comparison.error
# => root[:c][2] : expected String to be kind of Fixnum
```

### MiniTest
```ruby
require 'structure_compare'
require 'structure_compare/minitest'

assert_structures_equal({ a: 1, b: 2 }, { a: 1, b: 2 })
refute_structures_equal({ a: 1, b: 2 }, { c: 1, d: 2 })
```

### Options

#### Strict key ordering
name: `strict_key_order`
default: false

```ruby
expected = { a: 1, b: 2 }
actual   = { b: 2, a: 1 }

comparison = StructureCompare::StructureComparison.new(strict_key_order: false)
comparison.structures_are_equal?(expected, actual)
# => true
```

#### Value checking
name: `strict_key_order`
default: true

```ruby
expected = { a: 1, b: { c: 1 } }
actual   = { a: 8, b: { c: 8 } }

comparison = StructureCompare::StructureComparison.new
comparison.structures_are_equal?(expected, actual)
# => false

comparison = StructureCompare::StructureComparison.new(check_values: false)
comparison.structures_are_equal?(expected, actual)
# => true
```

#### Indifferent Access
Hash symbol keys are treated as equal to string keys
NOTE: an exception will be raised if there's a key present as symbol _and_ string

name: `indifferent_access`
default: false

expected = { a: 1 }
actual   = { "a" => 1 }

```ruby
comparison = StructureCompare::StructureComparison.new
comparison.structures_are_equal?(expected, actual)
# => false

comparison = StructureCompare::StructureComparison.new(indifferent_access: true)
comparison.structures_are_equal?(expected, actual)
# => true

hash = { a: 1, "a" => 2 }
comparison = StructureCompare::StructureComparison.new(indifferent_access: true)
comparison.structures_are_equal?(hash, hash)
# => StructureCompare::IndifferentAccessError
```

#### Float tolerance

When dealing with floats, you will want to introduce a tolerance.
NOTE: Float::EPSILON is _always_ used for comparing Float type values.
NOTE: The `check_values` option must be set.

name: `float_tolerance_factor`
default: 0

```
tolerance = +- (expected * (1.0 + tolerance_factor) + Float::EPSILON)
```

This means a `float_tolerance_factor` setting of 0.01 means that `actual`
can be 1% different from `expected` to still be treated equal.

```ruby
expected = { a: 10.0 }
actual_1 = { a: 10.1 }
actual_2 = { a: 10.11 }

# 1% tolerance factor
comparison = StructureCompare::StructureComparison.new(
  float_tolerance_factor: 0.01, check_values: true
)
comparison.structures_are_equal?(expected, actual_1)
# => true

comparison.structures_are_equal?(expected, actual_2)
# => false
```

## TODOS

RSpec helpers.

## Contribution

Fork me and send me a pull request with working tests.

## License

MIT License, see `LICENSE` file in the root directory
