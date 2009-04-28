require 'test/unit'
require 'rubygems'
require 'ruby-debug'
require 'mocha'

ENV["RAILS_ENV"] = "test"
RAILS_ROOT = "anywhere"

require 'active_support'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

# Add IR to load path and load the main file
ActiveSupport::Dependencies.load_paths << File.expand_path(File.dirname(__FILE__) + '/../lib')
require_dependency 'inherited_resources'

class ApplicationController < ActionController::Base; end

ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end
