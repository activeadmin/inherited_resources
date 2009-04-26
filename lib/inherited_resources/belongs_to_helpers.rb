module InheritedResources

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
  module BelongsToHelpers

    protected

      # Parent is always true when belongs_to is called.
      #
      def parent?
        true
      end

    private

      # Evaluate the parent given. This is used to nest parents in the
      # association chain.
      #
      def evaluate_parent(parent_config, chain = nil) #:nodoc:
        instantiated_object = instance_variable_get("@#{parent_config[:instance_name]}")
        return instantiated_object if instantiated_object

        scoped_parent = if chain
          chain.send(parent_config[:collection_name])
        else
          parent_config[:parent_class]
        end

        scoped_parent = scoped_parent.send(parent_config[:finder], params[parent_config[:param]])

        instance_variable_set("@#{parent_config[:instance_name]}", scoped_parent)
      end

      # Overwrites the end_of_association_chain method.
      #
      # This methods gets your begin_of_association_chain, join it with your
      # parents chain and returns the scoped association.
      #
      def end_of_association_chain #:nodoc:
        chain = symbols_for_chain.inject(begin_of_association_chain) do |chain, symbol|
          evaluate_parent(resources_configuration[symbol], chain)
        end

        return resource_class unless chain

        chain = chain.send(method_for_association_chain) if method_for_association_chain
        return chain
      end

      # If current controller is singleton, returns instance name to
      # end_of_association_chain. This means that we will have the following
      # chain:
      #
      #   Project.find(params[:project_id]).manager
      #
      # Instead of:
      #
      #   Project.find(params[:project_id]).managers
      #
      def method_for_association_chain #:nodoc:
        singleton ? nil : resource_collection_name
      end

      # Maps parents_symbols to build association chain. In this case, it
      # simply return the parent_symbols, however on polymorphic belongs to,
      # it has some customization.
      #
      def symbols_for_chain #:nodoc:
        parents_symbols
      end

  end
end
