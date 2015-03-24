# encoding: utf-8

require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

RuboCop::RakeTask.new(:rubocop) do |task|
  # NOTE: do not define task.patterns here, since this
  #       would override the .rubocop.yml include/exclude
  #       definition

  task.formatters = ['offenses', 'simple']
  task.options = ['-D'] # Display cop name

  # don't abort rake on failure
  task.fail_on_error = false
end

task default: [:test, :rubocop]
