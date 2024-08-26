# frozen_string_literal: true
if ENV.fetch('COVERAGE', false)
  require 'simplecov'
  require 'simplecov-cobertura'
  SimpleCov.start do
    add_filter %r{^/test/}
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
require 'minitest/autorun'
require 'minitest/reporters'

ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "anywhere"

require "active_support"
require "active_model"
require "action_controller"

# TODO: Remove warning gem and the following lines when freerange/mocha#593 will be fixed
require "warning"
Warning.ignore(/Mocha deprecation warning .+ expected keyword arguments .+ but received positional hash/)

require 'rails-controller-testing'
Rails::Controller::Testing.install

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

class ApplicationController < ActionController::Base; end

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
end
