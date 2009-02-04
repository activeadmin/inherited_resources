module InheritedResources #:nodoc:
  module SingletonHelpers #:nodoc:

    # Protected helpers. You might want to overwrite some of them.
    protected
      # Singleton methods does not deal with collections.
      #
      def collection
        nil
      end

      # Overwrites how singleton deals with resource.
      # If you are going to overwrite it, you should notice that the
      # end_of_association_chain here is not the same as in default belongs_to.
      #
      #   class TasksController < InheritedResources::Base
      #     belongs_to :project
      #   end
      #
      # In this case, the association chain would be:
      #
      #   Project.find(params[:project_id]).tasks
      #
      # So you would just have to call find(:all) at the end of association
      # chain. And this is what happened.
      #
      # In singleton controllers:
      #
      #   class ManagersController < InheritedResources::Base
      #     belongs_to :project, :singleton => true
      #   end
      #
      # The association chain will be:
      #
      #   Project.find(params[:project_id])
      #
      # So we have to call manager on it. And again, this is what happens.
      #
      def resource
        get_resource_ivar || set_resource_ivar(end_of_association_chain.send(resource_instance_name))
      end

    # Private helpers, you probably don't have to worry with them.
    private

      # Returns the appropriated method to build the resource.
      #
      def method_for_build
        "build_#{resource_instance_name}"
      end

  end
end
