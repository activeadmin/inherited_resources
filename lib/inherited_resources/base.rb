# = Inheriting
#
# To use InheritedResources you have to inherit from InheritedResources::Base
# class. This class have all Rails REST actions defined (index, show, new, edit
# update, create and destroy). The following definition is the same as a Rails
# scaffolded controller:
#
#   class ProjectController < InheritedResources::Base
#   end
#
# All actions are defined, check it!
#
# The next step is to define which mime types this controller provides:
#
#   class ProjectController < InheritedResources::Base
#     respond_to :html, :xml, :json
#   end
#
# You just said that this controller will respond to :html, :xml and :json. You
# can also specify it based on actions:
#
#   class ProjectController < InheritedResources::Base
#     respond_to :html, :xml, :json
#     respond_to :js, :only => :create
#     respond_to :csv, :except => [ :destroy ]
#   end
#
# How it works is simple. Let's suppose you have a json request on the action
# show. It will first try to render "projects/show.json.something". If it can't
# be found, it will call :to_json in the resource, which in this case is
# @project.
#
# If the resource @project doesn't respond to :to_json, we will render a 404
# Not Found.
#
# If you don't want to inherit all actions from InheritedResources::Base, call
# actions method with the actions you want to inherit:
#
#   class ProjectController < InheritedResources::Base
#     actions :index, :show, :new, :create, :edit, :update
#   end
#
# Or:
#
#   class ProjectController < InheritedResources::Base
#     actions :all, :except => :destroy
#   end
#
# = Extending the default behaviour
#
# Let's suppose that after destroying a project you want to redirect to your
# root url instead of redirecting to projects url. You just have to do:
#
#   class ProjectController < InheritedResources::Base
#     def destroy
#       super do |format|
#         format.html { redirect_to projects_url }
#       end
#     end
#   end
#
# super? Yes, we agree that calling super is the right thing but it does not
# look nice. That's why all methods have aliases. So this is equivalent:
#
#   class ProjectController < InheritedResources::Base
#     def destroy
#       destroy! do |format|
#         format.html { redirect_to projects_url }
#       end
#     end
#   end
#
# Since this is actually Ruby (and not a new DSL), if you want to do something
# before creating the project that is to small to deserve a before_filter, you
# could simply do:
#
#   class ProjectController < InheritedResources::Base
#     def create
#       # do something different!
#       create!
#     end
#   end
#
# And as instance variables are shared you can do more nice things.
# Let's suppose you want to create a project based on the current user:
#
#   class ProjectController < InheritedResources::Base
#     def create
#       @project = @current_user.projects.build(params[:project])
#       create!
#     end
#   end
#
# When you call create! the instance variable @project is already defined,
# so the method won't instanciate it again.
#
# The great thing is that we are not using blocks or nothing in special. We are
# just inheriting and calling the parent (super). You can extend even more
# without using blocks, please check helpers.rb for more info.
#
# = Flash and I18n
#
# Flash messages are changed through I18n API. If you have a ProjectsController,
# when a resource is updated with success, it will search for messages in the
# following order:
#
#   'flash.projects.update.notice'
#   'flash.actions.update.notice'
#
# If none of them are not available, it will show the default message:
#
#   Project was successfully updated.
#
# The message will be set into flash[:notice].
# Messages can be interpolated, so you can do the following in your I18n files:
#
#   flash:
#     actions:
#       update:
#         notice: "Hooray! {{resource}} was updated with success!"
#
# It will replace {{resource}} by Project.human_name, which is also localized
# (check http://rails-i18n.org/wiki/pages/i18n-rails-guide for more info).
#
# But sometimes, flash messages are not that simple. You might want to say the
# the name of the project when it's updated. Well, that's easy also:
#
#   flash:
#     projects:
#       update:
#         notice: "Dear manager, {{project_name}} was successfully updated!"
#
# Since :project_name is not available for interpolation by default, you
# have to overwrite interpolation_options method on your controller.
#
#   def interpolation_options
#     { :project_name => @project.quoted_name }
#   end
#
# Then you will finally have:
#
#   'Dear manager, "Make Rails Scale" was successfully updated!'
#
# Success messages appear on :create, :update and :destroy actions. Failure
# messages appear only on :create and :update.
#
# = Changing assumptions
#
# When you inherit from InheritedResources::Base, we make some assumptions on
# what is your resource_class, instance_name and collection_name.
#
# You can change those values by calling the class method defaults:
#
#   class PeopleController < InheritedResources::Base
#     defaults :resource_class => User, :instance_name => 'user', :collection_name => 'users'
#   end
#
# Further customizations can be done replacing some methods. Check
# base_helpers.rb file for more information.
#
module InheritedResources
  RESOURCES_ACTIONS = [ :index, :show, :new, :edit, :create, :update, :destroy ]

  class Base < ::ApplicationController
    include InheritedResources::BaseHelpers
    extend InheritedResources::BelongsTo
    extend InheritedResources::ClassMethods

    helper_method :collection_url, :collection_path, :resource_url, :resource_path,
                  :new_resource_url, :new_resource_path, :edit_resource_url, :edit_resource_path

    def self.inherited(base)
      base.class_eval do
        # Make all resources actions public
        public *RESOURCES_ACTIONS
      end

      # Call super to register class in ApplicationController
      super

      # Creates and sets class accessors default values
      initialize_resources_class_accessors!(base)
    end

    protected

      # GET /resources
      def index(&block)
        respond_to(:with => collection, &block)
      end
      alias :index! :index

      # GET /resources/1
      def show(&block)
        respond_to(:with => resource, &block)
      end
      alias :show! :show

      # GET /resources/new
      def new(&block)
        respond_to(:with => build_resource, &block)
      end
      alias :new! :new

      # GET /resources/1/edit
      def edit(&block)
        respond_to(:with => resource, &block)
      end
      alias :edit! :edit

      # POST /resources
      def create(&block)
        object = build_resource(params[resource_instance_name])

        if object.save
          set_flash_message!(:notice, '{{resource}} was successfully created.')

          respond_to(:with => object, :status => :created, :location => resource_url) do |format|
            yield(format) if block_given?
            format.html { redirect_to(resource_url) }
          end
        else
          set_flash_message!(:error)

          respond_to(:with => object.errors, :status => :unprocessable_entity) do |format|
            yield(format) if block_given?
            format.html { render :action => "new" }
          end
        end
      end
      alias :create! :create

      # PUT /resources/1
      def update(&block)
        object = resource

        if object.update_attributes(params[resource_instance_name])
          set_flash_message!(:notice, '{{resource}} was successfully updated.')

          respond_to do |format|
            yield(format) if block_given?
            format.html { redirect_to(resource_url) }
            format.all  { head :ok }
          end
        else
          set_flash_message!(:error)

          respond_to(:with => object.errors, :status => :unprocessable_entity) do |format|
            yield(format) if block_given?
            format.html { render :action => "edit" }
          end
        end
      end
      alias :update! :update

      # DELETE /resources/1
      def destroy(&block)
        resource.destroy

        set_flash_message!(:notice, '{{resource}} was successfully destroyed.')

        respond_to do |format|
          yield(format) if block_given?
          format.html { redirect_to(collection_url) }
          format.all  { head :ok }
        end
      end
      alias :destroy! :destroy

  end
end

