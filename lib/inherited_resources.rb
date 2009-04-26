# respond_to is the only file that should be loaded before hand. All others
# are loaded on demand.
#
require File.join(File.dirname(__FILE__), 'inherited_resources', 'respond_to')

module InheritedResources; end
