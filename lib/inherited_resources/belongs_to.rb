# = belongs_to
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
#   "admin_project_task_url" instead of "project_task_url", just do:
#
#     belongs_to :project, :route_name => "admin_project"
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
#   parent_instance #=> @task
#
# This polymorphic controllers thing is a great idea by James Golick and he
# built it in resource_controller. Here is just a re-implementation.
#
# = nested polymorphic associations
#
# You can have polymorphic associations with nested resources. Let's suppose
# that our File, Task and Message resources in the previous example belongs to
# a project.
#
# This way we can have:
#
#   class Comment < InheritedResources::Base
#     belongs_to :project {
#       belongs_to :file, :message, :task, :polymorphic => true
#     }
#   end
#
# Or:
#
#   class Comment < InheritedResources::Base
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
# If you have singleton resources, in other words, if your controller resource
# associates to another through a has_one association, you can pass the option
# :singleton to it. It will deal with all the details and automacally remove
# the :index action.
#
#   class ManagersController < InheritedResources::Base
#     belongs_to :project, :singleton => true # a project has one manager
#   end
#
module InheritedResources #:nodoc:
  module BelongsTo #:nodoc:

    protected
      def belongs_to(*symbols, &block)
        options = symbols.extract_options!

        options.symbolize_keys!
        options.assert_valid_keys(:class_name, :parent_class, :instance_name, :param, :finder, :route_name, :collection_name, :singleton, :polymorphic)

        acts_as_singleton!   if singleton   = options.delete(:singleton)
        acts_as_polymorphic! if polymorphic = options.delete(:polymorphic)

        raise ArgumentError, 'You have to give me at least one association name.' if symbols.empty?
        raise ArgumentError, 'You cannot define multiple associations with the options: #{options.keys.inspect}.' unless symbols.size == 1 || options.empty?

        # Add BelongsToHelpers if we haven't yet.
        include BelongsToHelpers if self.parents_symbols.empty?

        # Set configuration default values
        symbols.each do |symbol|
          symbol = symbol.to_sym

          if polymorphic
            self.parents_symbols     << :polymorphic unless self.parents_symbols.include? :polymorphic
            self.polymorphic_symbols << symbol
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
          config[:polymorphic]     = polymorphic
        end

        # Regenerate url helpers unless block is given
        if block_given?
          class_eval(&block)
        else
          InheritedResources::UrlHelpers.create_resources_url_helpers!(self)
        end
      end
      alias :nested_belongs_to :belongs_to

  end
end

