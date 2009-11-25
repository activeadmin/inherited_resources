module InheritedResources
  # Holds all default actions for InheritedResouces.
  module Actions

    # GET /resources
    def index(&block)
      respond_with(collection, &block)
    end
    alias :index! :index

    # GET /resources/1
    def show(&block)
      respond_with(resource, &block)
    end
    alias :show! :show

    # GET /resources/new
    def new(&block)
      respond_with(build_resource, &block)
    end
    alias :new! :new

    # GET /resources/1/edit
    def edit(&block)
      respond_with(resource, &block)
    end
    alias :edit! :edit

    # POST /resources
    def create(options={}, &block)
      object = build_resource

      if create_resource(object)
        set_flash_message!(:success, '{{resource_name}} was successfully created.')
        options[:location] ||= resource_url rescue nil
        respond_with_dual_blocks(object, options, true, block)
      else
        set_flash_message!(:failure)
        respond_with_dual_blocks(object, options, false, block)
      end
    end
    alias :create! :create

    # PUT /resources/1
    def update(options={}, &block)
      object = resource

      if update_resource(object, params[resource_instance_name])
        set_flash_message!(:success, '{{resource_name}} was successfully updated.')
        options[:location] ||= resource_url rescue nil
        respond_with_dual_blocks(object, options, true, block)
      else
        set_flash_message!(:failure)
        respond_with_dual_blocks(object, options, false, block)
      end
    end
    alias :update! :update

    # DELETE /resources/1
    def destroy(options={}, &block)
      object = resource
      options[:location] ||= collection_url rescue nil

      if destroy_resource(object)
        set_flash_message!(:success, '{{resource_name}} was successfully destroyed.')
        respond_with_dual_blocks(object, options, true, block)
      else
        set_flash_message!(:failure, '{{resource_name}} could not be destroyed.')
        respond_with_dual_blocks(object, options, false, block)
      end
    end
    alias :destroy! :destroy

    # Make aliases protected
    protected :index!, :show!, :new!, :create!, :edit!, :update!, :destroy!

  end
end

