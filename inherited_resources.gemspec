# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inherited_resources/version"

Gem::Specification.new do |s|
  s.name        = "inherited_resources"
  s.version     = InheritedResources::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
  s.homepage    = "http://github.com/josevalim/inherited_resources"
  s.description = "Inherited Resources speeds up development by making your controllers inherit all restful actions so you just have to focus on what is important."
  s.authors     = ['José Valim', 'Rafael Mendonça França']
  s.license     = "MIT"

  s.rubyforge_project = "inherited_resources"

  s.files         = Dir["app/**/*", "lib/**/*", "README.md", "MIT-LICENSE"]
  s.require_paths = ["lib"]

  s.add_dependency("responders")
  s.add_dependency("actionpack", ">= 3.2", "< 5")
  s.add_dependency("railties", ">= 3.2", "< 5")
  s.add_dependency("has_scope",  "~> 0.7.0")
end
