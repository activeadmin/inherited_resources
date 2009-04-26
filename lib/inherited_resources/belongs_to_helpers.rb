module InheritedResources

  # = belongs_to
  #
  # Finally, our Projects are going to get some Tasks. Then you create a
  # TasksController and do:
  #
  #    class TasksController < InheritedResources::Base
  #      belongs_to :project
  #    end
  #
  # belongs_to accepts several options to be able to configure the association.
  # Remember that our projects have pretty urls? So if you thought that url like
  # /projects/:project_title/tasks would be a problem, I can assure you it won't:
  #
  #    class TasksController < InheritedResources::Base
  #      belongs_to :project, :finder => :find_by_title!, :param => :project_title
  #    end
  #
  # It also accepts :route_name, :parent_class and :instance_name as options.
  # For more custmoization options, check the lib/inherited_resources/class_methods.rb.
  #
  # = nesteed_belongs_to
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
