# Whenever base is required load the dumb responder since it's used inside actions.
require File.dirname(__FILE__) + '/dumb_responder.rb'

module InheritedResources
  # Base helpers for InheritedResource work. Some methods here can be overwriten
  # and you will need to do that to customize your controllers from time to time.
  #
  module BaseHelpers

    protected

      # This is how the collection is loaded.
      #
      # You might want to overwrite this method if you want to add pagination
      # for example. When you do that, don't forget to cache the result in an
      # instance_variable:
      #
      #   def collection
      #     @projects ||= end_of_association_chain.paginate(params[:page]).all
      #   end
      #
      def collection
        get_collection_ivar || set_collection_ivar(end_of_association_chain.find(:all))
      end

      # This is how the resource is loaded.
      #
      # You might want to overwrite this method when you are using permalink.
      # When you do that, don't forget to cache the result in an
      # instance_variable:
      #
      #   def resource
      #     @project ||= end_of_association_chain.find_by_permalink!(params[:id])
      #   end
      #
      # You also might want to add the exclamation mark at the end of the method
      # because it will raise a 404 if nothing can be found. Otherwise it will
      # probably render a 500 error message.
      #
      def resource
        get_resource_ivar || set_resource_ivar(end_of_association_chain.find(params[:id]))
      end

      # This method is responsable for building the object on :new and :create
      # methods. If you overwrite it, don't forget to cache the result in an
      # instance variable.
      #
      def build_resource
        get_resource_ivar || set_resource_ivar(end_of_association_chain.send(method_for_build, params[resource_instance_name] || {}))
      end

      # Responsible for saving the resource on :create method. Overwriting this
      # allow you to control the way resource is saved. Let's say you have a
      # PassworsController who is responsible for finding an user by email and
      # sent password instructions for him. Instead of overwriting the entire
      # :create method, you could do something:
      #
      #   def create_resource(object)
      #     object.send_instructions_by_email
      #   end
      #
      def create_resource(object)
        object.save
      end

      # Responsible for updating the resource in :update method. This allow you
      # to handle how the resource is gona be updated, let's say in a different
      # way then the usual :update_attributes:
      #
      #   def update_resource(object, attributes)
      #     object.reset_password!(attributes)
      #   end
      #
      def update_resource(object, attributes)
        object.update_attributes(attributes)
      end

      # Handle the :destroy method for the resource. Overwrite it to call your
      # own method for destroing the resource, as:
      #
      #   def destroy_resource(object)
      #     object.cancel
      #   end
      #
      def destroy_resource(object)
        object.destroy
      end

      # This class allows you to set a instance variable to begin your
      # association chain. For example, usually your projects belongs to users
      # and that means that they belong to the current logged in user. So you
      # could do this:
      #
      #   def begin_of_association_chain
      #     @current_user
      #   end
      #
      # So every time we instantiate a project, we will do:
      #
      #   @current_user.projects.build(params[:project])
      #   @current_user.projects.find(params[:id])
      #
      # The variable set in begin_of_association_chain is not sent when building
      # urls, so this is never going to happen when calling resource_url:
      #
      #   project_url(@current_user, @project)
      #
      # If the user actually scopes the url, you should use belongs_to method
      # and declare that projects belong to user.
      #
      def begin_of_association_chain
        nil
      end

      # Returns if the controller has a parent. When only base helpers are loaded,
      # it's always false and should not be overwriten.
      #
      def parent?
        false
      end

      # Returns the association chain, with all parents (does not include the
      # current resource).
      #
      def association_chain
        @association_chain ||=
          symbols_for_association_chain.inject([begin_of_association_chain]) do |chain, symbol|
            chain << evaluate_parent(symbol, resources_configuration[symbol], chain.last)
          end.compact.freeze
      end

      # Overwrite this method to provide other interpolation options when
      # the flash message is going to be set.
      #
      # def interpolation_options
      #    { }
      # end

    private

      # Fast accessor to resource_collection_name
      #
      def resource_collection_name #:nodoc:
        self.resources_configuration[:self][:collection_name]
      end

      # Fast accessor to resource_instance_name
      #
      def resource_instance_name #:nodoc:
        self.resources_configuration[:self][:instance_name]
      end

      # This methods gets your begin_of_association_chain, join it with your
      # parents chain and returns the scoped association.
      #
      def end_of_association_chain #:nodoc:
        if chain = association_chain.last
          if method_for_association_chain
            apply_scope_to(chain.send(method_for_association_chain))
          else
            # This only happens when we specify begin_of_association_chain in
            # a singletion controller without parents. In this case, the chain
            # is exactly the begin_of_association_chain which is already an
            # instance and then not scopable.
            chain
          end
        else
          apply_scope_to(resource_class)
        end
      end

      # Returns the appropriated method to build the resource.
      #
      def method_for_build #:nodoc:
        (begin_of_association_chain || parent?) ? method_for_association_build : :new
      end

      # Returns the name of the method used for build the resource in cases
      # where we have a parent. This is overwritten in singleton scenarios.
      #
      def method_for_association_build
        :build
      end

      # Returns the name of the method to be called, before returning the end
      # of the association chain. This is overwriten by singleton cases
      # where no method for association chain is called.
      #
      def method_for_association_chain #:nodoc:
        resource_collection_name
      end

      # Get resource ivar based on the current resource controller.
      #
      def get_resource_ivar #:nodoc:
        instance_variable_get("@#{resource_instance_name}")
      end

      # Set resource ivar based on the current resource controller.
      #
      def set_resource_ivar(resource) #:nodoc:
        instance_variable_set("@#{resource_instance_name}", resource)
      end

      # Get collection ivar based on the current resource controller.
      #
      def get_collection_ivar #:nodoc:
        instance_variable_get("@#{resource_collection_name}")
      end

      # Set collection ivar based on the current resource controller.
      #
      def set_collection_ivar(collection) #:nodoc:
        instance_variable_set("@#{resource_collection_name}", collection)
      end

      # Helper to set flash messages. It's powered by I18n API.
      # It checks for messages in the following order:
      #
      #   flash.controller_name.action_name.status
      #   flash.actions.action_name.status
      #
      # If none is available, a default message is set. So, if you have
      # a CarsController, create action, it will check for:
      #
      #   flash.cars.create.status
      #   flash.actions.create.status
      #
      # The statuses can be :success (when the object can be created, updated
      # or destroyed with success) or :failure (when the objecy cannot be created
      # or updated).
      #
      # Those messages are interpolated by using the resource class human name.
      # This means you can set:
      #
      #   flash:
      #     actions:
      #       create:
      #         success: "Hooray! {{resource_name}} was successfully created!"
      #
      # But sometimes, flash messages are not that simple. Going back
      # to cars example, you might want to say the brand of the car when it's
      # updated. Well, that's easy also:
      #
      #   flash:
      #     cars:
      #       update:
      #         success: "Hooray! You just tuned your {{car_brand}}!"
      #
      # Since :car_name is not available for interpolation by default, you have
      # to overwrite interpolation_options.
      #
      #   def interpolation_options
      #     { :car_brand => @car.brand }
      #   end
      #
      # Then you will finally have:
      #
      #   'Hooray! You just tuned your Aston Martin!'
      #
      # If your controller is namespaced, for example Admin::CarsController,
      # the messages will be checked in the following order:
      #
      #   flash.admin.cars.create.status
      #   flash.admin.actions.create.status
      #   flash.cars.create.status
      #   flash.actions.create.status
      #
      def orig_set_flash_message!(status, default_message=nil)
        return flash[status] = default_message unless defined?(::I18n)

        resource_name = if resource_class
          if resource_class.respond_to?(:human_name)
            resource_class.human_name
          else
            resource_class.name.underscore.humanize
          end
        else
          "Resource"
        end

        given_options = if self.respond_to?(:interpolation_options)
          interpolation_options
        else
          {}
        end

        options = {
          :default  => default_message || '',
          :resource_name => resource_name
        }.merge(given_options)

        defaults = []
        slices   = controller_path.split('/')

        while slices.size > 0
          defaults << :"flash.#{slices.fill(controller_name, -1).join('.')}.#{action_name}.#{status}"
          defaults << :"flash.#{slices.fill(:actions, -1).join('.')}.#{action_name}.#{status}"
          slices.shift
        end

        options[:default] = defaults.push(options[:default])
        options[:default].flatten!

        message = ::I18n.t options[:default].shift, options
        flash[status] = message unless message.blank?
      end

      def set_flash_message!(status, default_message=nil)
        fallback = status == :success ? :notice : :error
        result   = orig_set_flash_message!(status)

        if result.blank?
          result = orig_set_flash_message!(fallback)

          if result.blank?
            result = orig_set_flash_message!(status, default_message) if default_message
          else
            ActiveSupport::Deprecation.warn "Using :#{fallback} in I18n with InheritedResources is deprecated, please use :#{status} instead"
          end
        end

        unless result.blank?
          flash[status]   = result
          flash[fallback] = ActiveSupport::Deprecation::DeprecatedObjectProxy.new result, "Accessing :#{fallback} in flash with InheritedResources is deprecated, please use :#{status} instead"
          result
        end
      end

      # Used to allow to specify success and failure within just one block:
      #
      #   def create
      #     create! do |success, failure|
      #       failure.html { redirect_to root_url }
      #     end
      #   end
      #
      # It also calculates the response url in case a block without arity is
      # given and returns it. Otherwise returns nil.
      #
      def respond_with_dual_blocks(object, options, success, given_block, &block) #:nodoc:
        case given_block.try(:arity)
          when 2
            respond_with(object, options) do |responder|
              dumb_responder = InheritedResources::DumbResponder.new
              if success
                given_block.call(responder, dumb_responder)
              else
                given_block.call(dumb_responder, responder)
              end
              block.try(:call, responder)
            end
          when 1
            if block
              respond_with(object, options) do |responder|
                given_block.call(responder)
                block.call(responder)
              end
            else
              respond_with(object, options, &given_block)
            end
          else
            options[:location] = given_block.call if given_block
            respond_with(object, options, &block)
        end
      end

      # Hook to apply scopes. By default returns only the target_object given.
      # It's extend by HasScopeHelpers.
      #
      def apply_scope_to(target_object) #:nodoc:
        target_object
      end

      # Symbols chain in base helpers return nothing. This is later overwriten
      # by belongs_to and can be complex in polymorphic cases.
      #
      def symbols_for_association_chain #:nodoc:
        []
      end

  end
end

