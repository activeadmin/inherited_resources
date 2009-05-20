# respond_to is the only file that should be loaded before hand. All others
# are loaded on demand.
#
require File.join(File.dirname(__FILE__), 'inherited_resources', 'respond_to')

module InheritedResources; end

class ActionController::Base
  class << self
    # If you cannot inherit from InheritedResources::Base you can call
    # inherit_resource or resource_controller in your controller to have all
    # the required modules and funcionality included.
    #
    def inherit_resources
      include InheritedResources::Actions
      include InheritedResources::BaseHelpers
      extend  InheritedResources::ClassMethods
      extend  InheritedResources::UrlHelpers

      helper_method :collection_url, :collection_path, :resource_url, :resource_path,
                    :new_resource_url, :new_resource_path, :edit_resource_url, :edit_resource_path,
                    :resource, :collection, :resource_class

      initialize_resources_class_accessors!
      create_resources_url_helpers!
    end
    alias :resource_controller :inherit_resources
  end
end
