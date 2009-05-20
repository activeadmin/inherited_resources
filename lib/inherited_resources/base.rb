module InheritedResources
  # = Base
  #
  # This is the base class that holds all actions. If you see the code for each
  # action, they are quite similar to Rails default scaffold.
  #
  # To change your base behavior, you can overwrite your actions and call super,
  # call <tt>default</tt> class method, call <<tt>actions</tt> class method
  # or overwrite some helpers in the base_helpers.rb file.
  #
  class Base < ::ApplicationController
    unloadable

    include InheritedResources::Actions
    include InheritedResources::BaseHelpers
    extend  InheritedResources::ClassMethods
    extend  InheritedResources::UrlHelpers

    helper_method :collection_url, :collection_path, :resource_url, :resource_path,
                  :new_resource_url, :new_resource_path, :edit_resource_url, :edit_resource_path,
                  :resource, :collection, :resource_class

    def self.inherited(base) #:nodoc:
      super(base)
      base.send :initialize_resources_class_accessors!
      base.send :create_resources_url_helpers!
    end
  end
end
