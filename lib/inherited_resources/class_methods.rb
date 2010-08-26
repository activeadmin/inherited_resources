module InheritedResources
  module ClassMethods

    protected

      # Used to overwrite the default assumptions InheritedResources do. Whenever
      # this method is called, it should be on the top of your controller, since
      # almost other methods depends on the values given to <<tt>>defaults</tt>.
      #
      # == Options
      #
      # * <tt>:resource_class</tt> - The resource class which by default is guessed
      #                              by the controller name. Defaults to Project in
      #                              ProjectsController.
      #
      # * <tt>:collection_name</tt> - The name of the collection instance variable which
      #                               is set on the index action. Defaults to :projects in
      #                               ProjectsController.
      #
      # * <tt>:instance_name</tt> - The name of the singular instance variable which
      #                             is set on all actions besides index action. Defaults to
      #                             :project in ProjectsController.
      #
      # * <tt>:route_collection_name</tt> - The name of the collection route. Defaults to :collection_name.
      #
      # * <tt>:route_instance_name</tt> - The name of the singular route. Defaults to :instance_name.
      #
      # * <tt>:route_prefix</tt> - The route prefix which is automically set in namespaced
      #                            controllers. Default to :admin on Admin::ProjectsController.
      #
      # * <tt>:singleton</tt> - Tells if this controller is singleton or not.
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

        create_resources_url_helpers!
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
        actions_to_remove = Array(options[:except])
        actions_to_remove += ACTIONS - actions_to_keep.map { |a| a.to_sym } unless actions_to_keep.first == :all
        actions_to_remove.map! { |a| a.to_sym }.uniq!
        (instance_methods.map { |m| m.to_sym } & actions_to_remove).each do |action|
          undef_method action, "#{action}!"
        end
      end

      # Defines that this controller belongs to another resource.
      #
      #   belongs_to :projects
      #
      # == Options
      #
      # * <tt>:parent_class</tt> - Allows you to specify what is the parent class.
      #
      #     belongs_to :project, :parent_class => AdminProject
      #
      # * <tt>:class_name</tt> - Also allows you to specify the parent class, but you should
      #                          give a string. Added for ActiveRecord belongs to compatibility.
      #
      # * <tt>:instance_name</tt> - The instance variable name. By default is the name of the association.
      #
      #     belongs_to :project, :instance_name => :my_project
      #
      # * <tt>:finder</tt> - Specifies which method should be called to instantiate the parent.
      #
      #     belongs_to :project, :finder => :find_by_title!
      #
      #   This will make your projects be instantiated as:
      #
      #     Project.find_by_title!(params[:project_id])
      #
      #   Instead of:
      #
      #     Project.find(params[:project_id])
      #
      # * <tt>:param</tt> - Allows you to specify params key to retrieve the id.
      #                     Default is :association_id, which in this case is :project_id.
      #
      # * <tt>:route_name</tt> - Allows you to specify what is the route name in your url
      #                          helper. By default is association name.
      #
      # * <tt>:collection_name</tt> - Tell how to retrieve the next collection. Let's
      #                               suppose you have Tasks which belongs to Projects
      #                               which belongs to companies. This will do somewhere
      #                               down the road:
      #
      #      @company.projects
      #
      #   But if you want to retrieve instead:
      #
      #      @company.admin_projects
      #
      #   You supply the collection name.
      #
      # * <tt>:polymorphic</tt> - Tell the association is polymorphic.
      #
      # * <tt>:singleton</tt> - Tell it's a singleton association.
      #
      # * <tt>:optional</tt> - Tell the association is optional (it's a special
      #                        type of polymorphic association)
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
        finder      = options.delete(:finder)

        include BelongsToHelpers if self.parents_symbols.empty?

        acts_as_singleton!   if singleton
        acts_as_polymorphic! if polymorphic || optional

        raise ArgumentError, 'You have to give me at least one association name.' if symbols.empty?
        raise ArgumentError, 'You cannot define multiple associations with options: #{options.keys.inspect} to belongs to.' unless symbols.size == 1 || options.empty?

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

          config[:parent_class] = options.delete(:parent_class) || begin
            class_name = (options.delete(:class_name) || symbol).to_s.pluralize.classify
            class_name.constantize
          rescue NameError => e
            raise unless e.message.include?(class_name)
            nil
          end

          config[:collection_name] = options.delete(:collection_name) || symbol.to_s.pluralize.to_sym
          config[:instance_name]   = options.delete(:instance_name) || symbol
          config[:param]           = options.delete(:param) || :"#{symbol}_id"
          config[:route_name]      = options.delete(:route_name) || symbol
          config[:finder]          = finder || :find
        end

        if block_given?
          class_eval(&block)
        else
          create_resources_url_helpers!
        end
        helper_method :parent, :parent?
      end
      alias :nested_belongs_to :belongs_to

      # A quick method to declare polymorphic belongs to.
      #
      def polymorphic_belongs_to(*symbols, &block)
        options = symbols.extract_options!
        options.merge!(:polymorphic => true)
        belongs_to(*symbols << options, &block)
      end

      # A quick method to declare singleton belongs to.
      #
      def singleton_belongs_to(*symbols, &block)
        options = symbols.extract_options!
        options.merge!(:singleton => true)
        belongs_to(*symbols << options, &block)
      end

      # A quick method to declare optional belongs to.
      #
      def optional_belongs_to(*symbols, &block)
        options = symbols.extract_options!
        options.merge!(:optional => true)
        belongs_to(*symbols << options, &block)
      end

    private

      def acts_as_singleton! #:nodoc:
        unless self.resources_configuration[:self][:singleton]
          self.resources_configuration[:self][:singleton] = true
          include SingletonHelpers
          actions :all, :except => :index
        end
      end

      def acts_as_polymorphic! #:nodoc:
        unless self.parents_symbols.include?(:polymorphic)
          include PolymorphicHelpers
          helper_method :parent_type, :parent_class
        end
      end

      # Initialize resources class accessors and set their default values.
      #
      def initialize_resources_class_accessors! #:nodoc:
        # Initialize resource class
        self.resource_class = begin
          class_name = self.controller_name.classify
          class_name.constantize
        rescue NameError => e
          raise unless e.message.include?(class_name)
          nil
        end

        # Initialize resources configuration hash
        self.resources_configuration ||= {}
        config = self.resources_configuration[:self] = {}
        config[:collection_name] = self.controller_name.to_sym
        config[:instance_name]   = self.controller_name.singularize.to_sym

        config[:route_collection_name] = config[:collection_name]
        config[:route_instance_name]   = config[:instance_name]

        # Deal with namespaced controllers
        namespaces = self.controller_path.split('/')[0..-2]
        config[:route_prefix] = namespaces.join('_') unless namespaces.empty?

        # Initialize polymorphic, singleton, scopes and belongs_to parameters
        self.parents_symbols ||= []
        self.resources_configuration[:polymorphic] ||= { :symbols => [], :optional => false }
      end

      # Hook called on inheritance.
      #
      def inherited(base) #:nodoc:
        super(base)
        base.send :initialize_resources_class_accessors!
        base.send :create_resources_url_helpers!
      end

  end
end
