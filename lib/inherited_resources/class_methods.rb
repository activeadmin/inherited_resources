module InheritedResources
  RESOURCES_CLASS_ACCESSORS = [ :resource_class, :resources_configuration, :parents_symbols, :singleton ] unless self.const_defined?(:RESOURCES_CLASS_ACCESSORS)

  module ClassMethods

    protected

      # When you inherit from InheritedResources::Base, we make some assumptions on
      # what is your resource_class, instance_name and collection_name.
      #
      # You can change those values by calling the class method <tt>defaults</tt>.
      # This is useful, for example, in an accounts controller, where the object
      # is an User but controller and routes are accounts.
      #
      #   class AccountController < InheritedResources::Base
      #     defaults :resource_class => User, :instance_name => 'user',
      #              :collection_name => 'users', :singleton => true
      #   end
      #
      # If you want to change your urls, you can use :route_instance_name and
      # :route_collection_name helpers.
      #
      # You can also provide :class_name, which is the same as :resource_class
      # but accepts string (this is given for ActiveRecord compatibility).
      #
      def defaults(options)
        raise ArgumentError, 'Class method :defaults expects a hash of options.' unless options.is_a? Hash

        options.symbolize_keys!
        options.assert_valid_keys(:resource_class, :collection_name, :instance_name,
                                  :class_name, :route_prefix, :route_collection_name,
                                  :route_instance_name, :singleton)

        self.resource_class = options.delete(:resource_class)         if options.key?(:resource_class)
        self.resource_class = options.delete(:class_name).constantize if options.key?(:class_name)

        acts_as_singleton! if options.delete(:singleton)

        config = self.resources_configuration[:self]
        config[:route_prefix] = options.delete(:route_prefix) if options.key?(:route_prefix)

        options.each do |key, value|
          config[key] = value.to_sym
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

      # Defines that this controller belongs to another resource.
      #
      #   belongs_to :projects
      #
      def belongs_to(*symbols, &block)
        options = symbols.extract_options!

        options.symbolize_keys!
        options.assert_valid_keys(:class_name, :parent_class, :instance_name, :param,
                                  :finder, :route_name, :collection_name, :singleton,
                                  :polymorphic, :optional)

        optional    = options.delete(:optional)
        singleton   = options.delete(:singleton)
        polymorphic = options.delete(:polymorphic)

        include BelongsToHelpers if self.parents_symbols.empty?

        acts_as_singleton!   if singleton
        acts_as_polymorphic! if polymorphic || optional

        raise ArgumentError, 'You have to give me at least one association name.' if symbols.empty?
        raise ArgumentError, 'You cannot define multiple associations with the options: #{options.keys.inspect}.' unless symbols.size == 1 || options.empty?

        symbols.each do |symbol|
          symbol = symbol.to_sym

          if polymorphic || optional
            self.parents_symbols << :polymorphic unless self.parents_symbols.include?(:polymorphic)
            self.resources_configuration[:polymorphic][:symbols]   << symbol
            self.resources_configuration[:polymorphic][:optional] ||= optional
          else
            self.parents_symbols << symbol
          end

          config = self.resources_configuration[symbol] = {}
          config[:parent_class]    = options.delete(:parent_class)
          config[:parent_class]  ||= (options.delete(:class_name) || symbol).to_s.classify.constantize rescue nil
          config[:collection_name] = (options.delete(:collection_name) || symbol.to_s.pluralize).to_sym
          config[:instance_name]   = (options.delete(:instance_name) || symbol).to_sym
          config[:param]           = (options.delete(:param) || "#{symbol}_id").to_sym
          config[:finder]          = (options.delete(:finder) || :find).to_sym
          config[:route_name]      = (options.delete(:route_name) || symbol).to_s
        end

        # Regenerate url helpers unless block is given
        if block_given?
          class_eval(&block)
        else
          InheritedResources::UrlHelpers.create_resources_url_helpers!(self)
        end
      end
      alias :nested_belongs_to :belongs_to

    private

      def acts_as_singleton! #:nodoc:
        unless self.singleton
          self.singleton = true
          include SingletonHelpers
          actions :all, :except => :index
        end
      end

      def acts_as_polymorphic! #:nodoc:
        unless self.parents_symbols.include? :polymorphic
          include PolymorphicHelpers
          helper_method :parent, :parent_type, :parent_class
        end
      end

      # Initialize resources class accessors and set their default values.
      #
      def initialize_resources_class_accessors!(base) #:nodoc:
        # Add and protect class accessors
        base.class_eval do
          metaklass = (class << self; self; end)

          RESOURCES_CLASS_ACCESSORS.each do |cattr|
            cattr_accessor "#{cattr}", :instance_writer => false

            # Protect instance methods
            self.send :protected, cattr

            # Protect class writer
            metaklass.send :protected, "#{cattr}="
          end
        end

        # Initialize resource class
        base.resource_class = begin
          base.controller_name.classify.constantize
        rescue NameError
          nil
        end

        # Initialize resources configuration hash
        base.resources_configuration = {}
        config = base.resources_configuration[:self] = {}
        config[:collection_name] = base.controller_name.to_sym
        config[:instance_name]   = base.controller_name.singularize.to_sym

        config[:route_collection_name] = config[:collection_name]
        config[:route_instance_name]   = config[:instance_name]

        # Deal with namespaced controllers
        namespaces = base.controller_path.split('/')[0..-2]
        config[:route_prefix] = namespaces.join('_') unless namespaces.empty?

        # Initialize polymorphic, singleton and belongs_to parameters
        base.singleton           = false
        base.parents_symbols     = []
        base.resources_configuration[:polymorphic] = { :symbols => [], :optional => false }

        # Create helpers
        InheritedResources::UrlHelpers.create_resources_url_helpers!(base)
      end

  end
end
