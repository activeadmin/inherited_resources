# frozen_string_literal: true

module InheritedResources

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
  #   resources :files do
  #     resources :comments #=> /files/13/comments
  #   end
  #   resources :tasks do
  #     resources :comments #=> /tasks/17/comments
  #   end
  #   resources :messages do
  #     resources :comments #=> /messages/11/comments
  #   end
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
  #   resources :projects do
  #     resources :files do
  #       resources :comments #=> /projects/1/files/13/comments
  #     end
  #     resources :tasks do
  #       resources :comments #=> /projects/1/tasks/17/comments
  #     end
  #     resources :messages do
  #       resources :comments #=> /projects/1/messages/11/comments
  #     end
  #   end
  #
  # The helpers work in the same way as above.
  #
  module PolymorphicHelpers

    protected

      # Returns the parent type. A Comments class can have :task, :file, :note
      # as parent types.
      #
      def parent_type
        unless instance_variable_defined?(:@parent_type)
          symbols_for_association_chain
        end

        if instance_variable_defined?(:@parent_type)
          @parent_type
        end
      end

      def parent_class
        parent.class if parent_type
      end

      # Returns the parent object. They are also available with the instance
      # variable name: @task, @file, @note...
      #
      def parent
        if parent_type
          p = instance_variable_defined?("@#{parent_type}") && instance_variable_get("@#{parent_type}")
          p || instance_variable_set("@#{parent_type}", association_chain[-1])
        end
      end

      # If the polymorphic association is optional, we might not have a parent.
      #
      def parent?
        if resources_configuration[:polymorphic][:optional]
          parents_symbols.size > 1 || !parent_type.nil?
        else
          true
        end
      end

    private

      # Maps parents_symbols to build association chain.
      #
      # If the parents_symbols find :polymorphic, it goes through the
      # params keys to see which polymorphic parent matches the given params.
      #
      # When optional is given, it does not raise errors if the polymorphic
      # params are missing.
      #
      def symbols_for_association_chain #:nodoc:
        polymorphic_config = resources_configuration[:polymorphic]
        parents_symbols.map do |symbol|
          if symbol == :polymorphic
            params_keys = params.keys

            keys = polymorphic_config[:symbols].map do |poly|
              params_keys.include?(resources_configuration[poly][:param].to_s) ? poly : nil
            end.compact

            if keys.empty?
              raise ScriptError, "Could not find param for polymorphic association. The request " <<
                                 "parameters are #{params.keys.inspect} and the polymorphic " <<
                                 "associations are #{polymorphic_config[:symbols].inspect}." unless polymorphic_config[:optional]

              nil
            else
              @parent_type = keys[-1].to_sym
              @parent_types = keys.map(&:to_sym)
            end
          else
            symbol
          end
        end.flatten.compact
      end

  end
end
