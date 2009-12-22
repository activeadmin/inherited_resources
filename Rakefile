# encoding: UTF-8

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'inherited_resources', 'version')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "inherited_resources"
    s.version = InheritedResources::VERSION
    s.rubyforge_project = "inherited_resources"
    s.summary = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
    s.email = "jose.valim@gmail.com"
    s.homepage = "http://github.com/josevalim/inherited_resources"
    s.description = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
    s.authors = ['José Valim']
    s.files =  FileList["[A-Z]*", "{lib}/**/*"]
    s.add_dependency("responders", ">= 0.2.0")
    s.add_dependency("has_scope",  ">= 0.3.0")
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc 'Run tests for InheritedResources.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
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
