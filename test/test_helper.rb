require 'rubygems'

begin
  gem "test-unit"
rescue LoadError
end

begin
  gem "ruby-debug"
  require 'ruby-debug'
rescue LoadError
end

require 'test/unit'
require 'mocha'

ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "anywhere"

require "active_support"
require "active_model"

require "action_controller"
require "action_dispatch/middleware/flash"

require "rails/railtie"

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

class ApplicationController < ActionController::Base; end

# Add IR to load path and load the main file
ActiveSupport::Dependencies.load_paths << File.expand_path(File.dirname(__FILE__) + '/../lib')
require_dependency 'inherited_resources'

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

InheritedResources::Router = ActionDispatch::Routing::RouteSet.new
InheritedResources::Router.draw do |map|
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action'
end

class ActiveSupport::TestCase
  setup do
    @router = InheritedResources::Router
  end
end
