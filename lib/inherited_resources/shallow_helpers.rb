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
        parent_symbols = parents_symbols.dup
        if parents_symbols.size > 1 && !params[:id]
          inst_class_name = parent_symbols.pop
          finder_method = resources_configuration[inst_class_name][:finder] || :find
          instance = resources_configuration[inst_class_name][:parent_class].send(finder_method, params[resources_configuration[inst_class_name][:param]])
          load_parents(instance, parent_symbols)
        end
        if params[:id]
          finder_method = resources_configuration[:self][:finder] || :find
          instance = self.resource_class.send(finder_method, params[:id])
          load_parents(instance, parent_symbols)
        end
        parents_symbols
      end

      def load_parents(instance, parent_symbols)

        parent_symbols.reverse.each do |parent|
          instance = instance.send(parent)
          params[resources_configuration[parent][:param]] = instance.to_param
        end
      end
  end

end
