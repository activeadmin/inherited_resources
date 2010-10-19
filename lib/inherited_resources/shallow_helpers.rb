module InheritedResources
  # = belongs_to
  #
  # Let's suppose that we have some tasks that belongs to projects. To specify
  # this assoication in your controllers, just do:
  #
  #    class TasksController < InheritedResources::Base
  #      belongs_to :project
  #    end
  #
  # belongs_to accepts several options to be able to configure the association.
  # For example, if you want urls like /projects/:project_title/tasks, you
  # can customize how InheritedResources find your projects:
  #
  #    class TasksController < InheritedResources::Base
  #      belongs_to :project, :finder => :find_by_title!, :param => :project_title
  #    end
  #
  # It also accepts :route_name, :parent_class and :instance_name as options.
  # Check the lib/inherited_resources/class_methods.rb for more.
  #
  # = nested_belongs_to
  #
  # Now, our Tasks get some Comments and you need to nest even deeper. Good
  # practices says that you should never nest more than two resources, but sometimes
  # you have to for security reasons. So this is an example of how you can do it:
  #
  #    class CommentsController < InheritedResources::Base
  #      nested_belongs_to :project, :task
  #    end
  #
  # If you need to configure any of these belongs to, you can nested them using blocks:
  #
  #    class CommentsController < InheritedResources::Base
  #      belongs_to :project, :finder => :find_by_title!, :param => :project_title do
  #        belongs_to :task
  #      end
  #    end
  #
  # Warning: calling several belongs_to is the same as nesting them:
  #
  #    class CommentsController < InheritedResources::Base
  #      belongs_to :project
  #      belongs_to :task
  #    end
  #
  # In other words, the code above is the same as calling nested_belongs_to.
  #
  module ShallowHelpers
    include BelongsToHelpers

    private

      # Evaluate the parent given. This is used to nest parents in the
      # association chain.
      #

      # Maps parents_symbols to build association chain. In this case, it
      # simply return the parent_symbols, however on polymorphic belongs to,
      # it has some customization.
      #
      def symbols_for_association_chain #:nodoc:
        if params[:id]
          inst = resources_configuration[:self][:instance_name].to_s.camelize.constantize.find(params[:id])
          parents_symbols.reverse.each do |parent|
            inst = inst.send(resources_configuration[parent][:instance_name])
            params[resources_configuration[parent][:param]] = inst.id
          end
        end
        parents_symbols
      end

  end

end
