dir = File.dirname(__FILE__)
require File.join(dir, 'inherited_resources', 'respond_to')

unless defined?(ApplicationController)
  class ApplicationController < ActionController::Base; end
end

module InheritedResources; end

# Load InheritedResources::Base after defining ApplicationController
require File.dirname(__FILE__) + '/../lib/inherited_resources/base_helpers.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/belongs_to.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/belongs_to_helpers.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/class_methods.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/dumb_responder.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/polymorphic_helpers.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/singleton_helpers.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/url_helpers.rb'
require File.dirname(__FILE__) + '/../lib/inherited_resources/base.rb'
