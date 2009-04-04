require 'test/unit'
require 'rubygems'
require 'mocha'

ENV["RAILS_ENV"] = "test"

require 'active_support'
require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/test_process'

I18n.load_path << File.join(File.dirname(__FILE__), 'locales', 'en.yml')
I18n.reload!

# Load respond_to before defining ApplicationController
require File.dirname(__FILE__) + '/../lib/inherited_resources/respond_to.rb'

# Define ApplicationController
class ApplicationController < ActionController::Base; end

# Load InheritedResources::Base after defining ApplicationController
require File.dirname(__FILE__) + '/../lib/inherited_resources/base.rb'

# Define view_paths
ActionController::Base.view_paths = File.join(File.dirname(__FILE__), 'views')

# Define default routes
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end
