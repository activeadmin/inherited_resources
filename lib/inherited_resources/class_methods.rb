# = belongs to
#
# This allows you to specify to belongs_to in your controller. You might use
# this when you are having nested resources in your routes:
#
#   class TasksController < InheritedResources::Base
#     belongs_to :project
#   end
#
# This will do all magic assuming some defaults. It assumes that your URL to
# access those tasks are:
#
#   /projects/:project_id/tasks
#
# But all defaults are configurable. The options are:
#
# * :parent_class => Allows you to specify what is the parent class.
#
#     belongs_to :project, :parent_class => AdminProject
#
# * :class_name => Also allows you to specify the parent class, but you should
#   give a string. Added for ActiveRecord belongs to compatibility.
#
# * :instance_name => How this object will appear in your views. In this case
#   the default is @project. Overwrite it with a symbol.
#
#     belongs_to :project, :instance_name => :my_project
#
# * :finder => Specifies which method should be called to instantiate the
#   parent. Let's suppose you are using slugs ("this-is-project-title") in URLs
#   so your tasks url would be: "projects/this-is-project-title/tasks". Then you
#   should do this in your TasksController:
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
# * param => Allows you to specify params key used to instantiate the parent.
#   Default is :parent_id, which in this case is :project_id.
#
# * route_name => Allows you to specify what is the route name in your url
#   helper. By default is 'project'. But if your url helper should be
#   "myproject_task_url" instead of "project_task_url", just do:
#
#     belongs_to :project, :route_name => "myproject"
#
#   But if you want to use namespaced routes, you can do:
#
#     defaults :route_prefix => :admin
#
#   That would generate "admin_project_task_url".
#
# = nested_belongs_to
#
# If for some reason you need to nested more than two resources, you can do:
#
#   class TasksController
#     belongs_to :company, :project
#   end
#
# ATTENTION! This DOES NOT mean polymorphic associations as in resource_controller.
# Polymorphic associations are not supported yet.
#
# It means that companies have many projects which have many tasks. You URL
# should be:
#
#   /companies/:company_id/projects/:project_id/tasks/:id
#
# Everything will be handled for you again. And all defaults will describe above
# will be assumed. But if you have to change the defaults. You will have to
# specify one association by one:
#
#   class TasksController
#     belongs_to :company, :finder => :find_by_name!, :param => :company_name
#     belongs_to :project
#   end
#
# belongs_to is aliased as nested_belongs_to, so this provides a nicer syntax:
#
#   class TasksController
#     nested_belongs_to :company, :finder => :find_by_name!, :param => :company_name
#     nested_belongs_to :project
#   end
#
# In this case the association chain would be:
#
#   Company.find_by_name!(params[:company_name]).projects.find(params[:project_id]).tasks.find(:all)
#
# When you are using nested resources, you have one more option to config.
# Let's suppose that to get all projects from a company, you have to do:
#
#   Company.admin_projects
#
# Instead of:
#
#   Company.projects
#
# In this case, you can set the collection_name in belongs_to:
#
#   nested_belongs_to :project, :collection_name => 'admin_projects'
#
# = polymorphic associations
#
# In some cases you have a resource that belongs to two different resources
# but not at the same time. For example, let's suppose you have File, Message
# and Task as resources and they are all commentable.
#
# Polymorphic associations allows you to create just one controller that will
# deal with each case.
#
#   class Comment < InheritedResources::Base
#     belongs_to :file, :message, :task, :polymorphic => true
#   end
#
# Your routes should be something like:
#
#   m.resources :files,    :has_many => :comments #=> /files/13/comments
#   m.resources :tasks,    :has_many => :comments #=> /tasks/17/comments
#   m.resources :messages, :has_many => :comments #=> /messages/11/comments
#
# When using polymorphic associations, you get some free helpers:
#
#   parent?         #=> true
#   parent_type     #=> :task
#   parent_class    #=> Task
#   parent          #=> @task
#
# This polymorphic controllers thing is a great idea by James Golick and he
# built it in resource_controller. Here is just a re-implementation.
#
# = optional polymorphic associations
#
# Let's take another break from ProjectsController. Let's suppose we are
# building a store, which sell products.
#
# On the website, we can show all products, but also products scoped to
# categories, brands, users. In this case case, the association is optional, and
# we deal with it in the following way:
#
#   class ProductsController < InheritedResources::Base
#     belongs_to :category, :brand, :user, :polymorphic => true, :optional => true
#   end
#
# This will handle all those urls properly:
#
#   /products/1
#   /categories/2/products/5
#   /brands/10/products/3
#   /user/13/products/11
#
# = nested polymorphic associations
#
# You can have polymorphic associations with nested resources. Let's suppose
# that our File, Task and Message resources in the previous example belongs to
# a project.
#
# This way we can have:
#
#   class CommentsController < InheritedResources::Base
#     belongs_to :project {
#       belongs_to :file, :message, :task, :polymorphic => true
#     }
#   end
#
# Or:
#
#   class CommentsController < InheritedResources::Base
#     nested_belongs_to :project
#     nested_belongs_to :file, :message, :task, :polymorphic => true
#   end
#
# Choose the syntax that makes more sense to you. :)
#
# Finally your routes should be something like:
#
#   map.resources :projects do |m|
#     m.resources :files,    :has_many => :comments #=> /projects/1/files/13/comments
#     m.resources :tasks,    :has_many => :comments #=> /projects/1/tasks/17/comments
#     m.resources :messages, :has_many => :comments #=> /projects/1/messages/11/comments
#   end
#
# The helpers work in the same way as above.
#
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
  RESOURCES_CLASS_ACCESSORS = [ :resource_class, :resources_configuration, :parents_symbols, :singleton ] unless self.const_defined? "RESOURCES_CLASS_ACCESSORS"

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
        options.assert_valid_keys(:resource_class, :collection_name, :instance_name,
                                  :class_name, :route_prefix, :singleton)

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

        # Add BelongsToHelpers if we haven't yet.
        include BelongsToHelpers if self.parents_symbols.empty?

        acts_as_singleton!   if singleton
        acts_as_polymorphic! if polymorphic || optional

        raise ArgumentError, 'You have to give me at least one association name.' if symbols.empty?
        raise ArgumentError, 'You cannot define multiple associations with the options: #{options.keys.inspect}.' unless symbols.size == 1 || options.empty?

        # Set configuration default values
        symbols.each do |symbol|
          symbol = symbol.to_sym

          if polymorphic || optional
            self.parents_symbols << :polymorphic unless self.parents_symbols.include? :polymorphic
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
        unless self.parents_symbols.include? :polymorphic
          include PolymorphicHelpers
          helper_method :parent, :parent_type, :parent_class
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
        base.resources_configuration[:polymorphic] = { :symbols => [], :optional => false }

        # Create helpers
        InheritedResources::UrlHelpers.create_resources_url_helpers!(base)
      end

  end
end
