# respond_to is the only file that should be loaded before hand. All others
# are loaded on demand.
#
unless defined?(ActionController::Responder)
  require 'inherited_resources/legacy/responder'
  require 'inherited_resources/legacy/respond_to'
end

require 'responders'
I18n.load_path.unshift File.expand_path(File.join(File.dirname(__FILE__), 'inherited_resources', 'locales', 'en.yml'))

module InheritedResources
  ACTIONS = [ :index, :show, :new, :edit, :create, :update, :destroy ] unless self.const_defined?(:ACTIONS)

  autoload :Actions,            'inherited_resources/actions'
  autoload :Base,               'inherited_resources/base'
  autoload :BaseHelpers,        'inherited_resources/base_helpers'
  autoload :BelongsToHelpers,   'inherited_resources/belongs_to_helpers'
  autoload :ClassMethods,       'inherited_resources/class_methods'
  autoload :DSL,                'inherited_resources/dsl'
  autoload :PolymorphicHelpers, 'inherited_resources/polymorphic_helpers'
  autoload :SingletonHelpers,   'inherited_resources/singleton_helpers'
  autoload :UrlHelpers,         'inherited_resources/url_helpers'
  autoload :VERSION,            'inherited_resources/version'

  # Change the flash keys used by FlashResponder.
  def self.flash_keys=(array)
    Responders::FlashResponder.flash_keys = array
  end
end

class ActionController::Base
  public :flash, :render

  # If you cannot inherit from InheritedResources::Base you can call
  # inherit_resource in your controller to have all the required modules and
  # funcionality included.
  def self.inherit_resources
    InheritedResources::Base.inherit_resources(self)
    initialize_resources_class_accessors!
    create_resources_url_helpers!
  end
end