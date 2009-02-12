# = singleton
#
# Singletons are usually used in associations which are related through has_one
# and belongs_to. You declare those associations like this:
#
#   class ManagersController < InheritedResources::Base
#     belongs_to :project, :singleton => true
#   end
#
# But in some cases, like an AccountsController, you have a singleton object
# that is not necessarily associated with another:
#
#   class AccountsController < InheritedResources::Base
#     defaults :singleton => true
#   end
#
# Besides that, you should overwrite the methods :resource and :build_resource
# to make it work properly:
#
#   class AccountsController < InheritedResources::Base
#     defaults :singleton => true
#
#     protected
#       def resource
#         @current_user.account
#       end
#
#       def build_resource(attributes = {})
#         Account.new(attributes)
#       end
#   end
#
# When you have a singleton controller, the action index is removed.
#
module InheritedResources #:nodoc:
  RESOURCES_CLASS_ACCESSORS = [ :resource_class, :resources_configuration, :parents_symbols, :singleton, :polymorphic_symbols ] unless self.const_defined? "RESOURCES_CLASS_ACCESSORS"

  module ClassMethods #:nodoc:

    protected

      # When you inherit from InheritedResources::Base, we make some assumptions on
      # what is your resource_class, instance_name and collection_name.
      #
      # You can change those values by calling the class method defaults:
      #
      #   class PeopleController < InheritedResources::Base
      #     defaults :resource_class => User, :instance_name => 'user', :collection_name => 'users'
      #   end
      #
      # You can also provide :class_name, which is the same as :resource_class
      # but accepts string (this is given for ActiveRecord compatibility).
      #
      def defaults(options)
        raise ArgumentError, 'Class method :defaults expects a hash of options.' unless options.is_a? Hash

        options.symbolize_keys!
        options.assert_valid_keys(:resource_class, :collection_name, :instance_name, :class_name, :singleton)

        # Checks for special argument :resource_class and :class_name and sets it right away.
        self.resource_class = options.delete(:resource_class)         if options[:resource_class]
        self.resource_class = options.delete(:class_name).constantize if options[:class_name]

        acts_as_singleton! if options.delete(:singleton)

        options.each do |key, value|
          self.resources_configuration[:self][key] = value.to_sym
        end

        InheritedResources::UrlHelpers.create_resources_url_helpers!(self)
      end

      # Defines wich actions to keep from the inherited controller.
      # Syntax is borrowed from resource_controller.
      #
      #   actions :index, :show, :edit
      #   actions :all, :except => :index
      #
      def actions(*actions_to_keep)
        raise ArgumentError, 'Wrong number of arguments. You have to provide which actions you want to keep.' if actions_to_keep.empty?

        options = actions_to_keep.extract_options!
        actions_to_keep.map!{ |a| a.to_s }

        actions_to_remove = Array(options[:except])
        actions_to_remove.map!{ |a| a.to_s }

        actions_to_remove += RESOURCES_ACTIONS.map{|a| a.to_s } - actions_to_keep unless actions_to_keep.first == 'all'
        actions_to_remove.uniq!

        # Undefine actions that we don't want
        (instance_methods & actions_to_remove).each do |action|
          undef_method action, "#{action}!"
        end
      end

    private

      # Defines this controller as singleton.
      # You can call this method to define your controller as singleton.
      #
      def acts_as_singleton!
        unless self.singleton
          self.singleton = true
          include SingletonHelpers
          actions :all, :except => :index
        end
      end

      # Defines this controller as polymorphic.
      # Do not call this method on your own.
      #
      def acts_as_polymorphic!
        if self.polymorphic_symbols.empty?
          include PolymorphicHelpers
          helper_method :parent?, :parent_type, :parent_class, :parent
        end
      end

      # Initialize resources class accessors by creating the accessors
      # and setting their default values.
      #
      def initialize_resources_class_accessors!(base)
        # Add and protect class accessors
        base.class_eval do
          RESOURCES_CLASS_ACCESSORS.each do |cattr|
            cattr_accessor "#{cattr}", :instance_writer => false

            # Protect instance methods
            self.send :protected, cattr

            # Protect class writer
            metaclass.send :protected, "#{cattr}="
          end
        end

        # Initialize resource class
        base.resource_class = base.controller_name.classify.constantize rescue nil

        # Initialize resources configuration hash
        base.resources_configuration = {}
        config = base.resources_configuration[:self] = {}
        config[:collection_name] = base.controller_name.to_sym
        config[:instance_name]   = base.controller_name.singularize.to_sym

        # Initialize polymorphic, singleton and belongs_to parameters
        base.singleton           = false
        base.parents_symbols     = []
        base.polymorphic_symbols = []

        # Create helpers
        InheritedResources::UrlHelpers.create_resources_url_helpers!(base)
      end

  end
end
