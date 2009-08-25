module InheritedResources
  RESOURCES_ACTIONS = [ :index, :show, :new, :edit, :create, :update, :destroy ] unless self.const_defined?(:RESOURCES_ACTIONS)

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

      if object.save
        set_flash_message!(:notice, '{{resource_name}} was successfully created.')
        options[:location] ||= resource_url rescue nil
        respond_with_dual_blocks(object, options, true, block)
      else
        set_flash_message!(:error)
        respond_with_dual_blocks(object, options, false, block)
      end
    end
    alias :create! :create

    # PUT /resources/1
    def update(options={}, &block)
      object = resource

      if object.update_attributes(params[resource_instance_name])
        set_flash_message!(:notice, '{{resource_name}} was successfully updated.')
        options[:location] ||= resource_url rescue nil
        respond_with_dual_blocks(object, options, true, block)
      else
        set_flash_message!(:error)
        respond_with_dual_blocks(object, options, false, block)
      end
    end
    alias :update! :update

    # DELETE /resources/1
    def destroy(options={}, &block)
      object = resource
      object.destroy

      set_flash_message!(:notice, '{{resource_name}} was successfully destroyed.')
      options[:location] ||= collection_url rescue nil
      respond_with_dual_blocks(object, options, nil, block)
    end
    alias :destroy! :destroy

    # Make aliases protected
    protected :index!, :show!, :new!, :create!, :edit!, :update!, :destroy!

  end
end
