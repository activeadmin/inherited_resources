# frozen_string_literal: true
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rdoc/task'

desc 'Run tests for InheritedResources.'
Rake::TestTask.new(:test) do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs << "test"
  t.libs << "lib"
  t.verbose = true
end

desc 'Generate documentation for InheritedResources.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'InheritedResources'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :rubocop do
  sh('bin/rubocop')
end

task default: [:test, :rubocop]
