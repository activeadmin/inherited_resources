# Whenever Base is required, we eager load the base files. belongs_to, polymorphic
# and singleton helpers are loaded on demand.
require File.dirname(__FILE__) + '/base_helpers.rb'
require File.dirname(__FILE__) + '/class_methods.rb'
require File.dirname(__FILE__) + '/dumb_responder.rb'
require File.dirname(__FILE__) + '/url_helpers.rb'

module InheritedResources
  RESOURCES_ACTIONS = [ :index, :show, :new, :edit, :create, :update, :destroy ] unless self.const_defined?(:RESOURCES_ACTIONS)

  # = Base
  #
  # This is the base class that holds all actions. If you see the code for each
  # action, they are quite similar to Rails default scaffold.
  #
  # To change your base behavior, you can overwrite your actions and call super,
  # call <tt>default</tt> class method, call <<tt>actions</tt> class method
  # or overwrite some helpers in the base_helpers.rb file.
  #
  class Base < ::ApplicationController
    unloadable

    include InheritedResources::BaseHelpers
    extend InheritedResources::ClassMethods

    helper_method :collection_url, :collection_path, :resource_url, :resource_path,
                  :new_resource_url, :new_resource_path, :edit_resource_url, :edit_resource_path,
                  :resource, :collection, :resource_class, :parent?

    def self.inherited(base) #:nodoc:
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
      def create(redirect_to=nil, &block)
        object = build_resource(params[resource_instance_name])

        if object.save
          set_flash_message!(:notice, '{{resource_name}} was successfully created.')

          options = { :with => object, :status => :created, :location => (resource_url rescue nil) }

          respond_to_with_dual_blocks(true, block, options) do |format|
            format.html { redirect_to(redirect_to || resource_url) }
          end
        else
          set_flash_message!(:error)

          options = { :with => object.errors, :status => :unprocessable_entity }

          respond_to_with_dual_blocks(false, block, options) do |format|
            format.html { render :action => 'new' }
          end
        end
      end
      alias :create! :create

      # PUT /resources/1
      def update(redirect_to=nil, &block)
        object = resource

        if object.update_attributes(params[resource_instance_name])
          set_flash_message!(:notice, '{{resource_name}} was successfully updated.')

          respond_to_with_dual_blocks(true, block) do |format|
            format.html { redirect_to(redirect_to || resource_url) }
            format.all  { head :ok }
          end
        else
          set_flash_message!(:error)

          options = { :with => object.errors, :status => :unprocessable_entity }

          respond_to_with_dual_blocks(false, block, options) do |format|
            format.html { render :action => 'edit' }
          end
        end
      end
      alias :update! :update

      # DELETE /resources/1
      def destroy(redirect_to=nil, &block)
        resource.destroy

        set_flash_message!(:notice, '{{resource_name}} was successfully destroyed.')

        respond_to_with_dual_blocks(nil, block) do |format|
          format.html { redirect_to(redirect_to || collection_url) }
          format.all  { head :ok }
        end
      end
      alias :destroy! :destroy

  end
end

