# frozen_string_literal: true
if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.start do
    enable_coverage :branch
    minimum_coverage 98
    maximum_coverage_drop 0.2
    formatter SimpleCov::Formatter::CoberturaFormatter
  end
end

require 'rubygems'
require 'bundler'

Bundler.setup

require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/reporters'

ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "anywhere"

require "active_support"
require "active_model"
require "action_controller"

require 'rails-controller-testing'
Rails::Controller::Testing.install

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

class ApplicationController < ActionController::Base
end

# Add IR to load path and load the main file
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'inherited_resources'

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

InheritedResources::Routes = ActionDispatch::Routing::RouteSet.new

def draw_routes(&block)
  InheritedResources::Routes.draw(&block)
end

def clear_routes
  InheritedResources::Routes.draw { }
end

ActionController::Base.send :include, InheritedResources::Routes.url_helpers

# Add app base to load path
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../app/controllers')
require 'inherited_resources/base'

class ActiveSupport::TestCase
  setup do
    @routes = InheritedResources::Routes
  end

  # Builds an anonymous controller that uses Inherited Resources, so a test can
  # configure a controller of its own instead of one shared with other tests.
  #
  # Inherited Resources derives the model, instance variable names, and routes
  # from the controller's name. The name is defined before calling
  # `inherit_resources`, which a class created with Class.new wouldn't have yet.
  # Subclasses of the returned controller have the same name.
  def build_controller(name, &body)
    Class.new(ApplicationController) do
      define_singleton_method(:name) { name }
      inherit_resources
      class_eval(&body) if body
    end
  end
end
