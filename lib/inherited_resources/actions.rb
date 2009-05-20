module InheritedResources
  RESOURCES_ACTIONS = [ :index, :show, :new, :edit, :create, :update, :destroy ] unless self.const_defined?(:RESOURCES_ACTIONS)

  # Holds all default actions for InheritedResouces.
  module Actions

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
    def create(redirect_url=nil, &block)
      object = build_resource(params[resource_instance_name])
      respond_block, redirect_block = select_block_by_arity(block)

      if object.save
        set_flash_message!(:notice, '{{resource_name}} was successfully created.')
        options = { :with => object, :status => :created, :location => (resource_url rescue nil) }

        respond_to_with_dual_blocks(true, respond_block, options) do |format|
          format.html { redirect_to(redirect_block ? redirect_block.call : resource_url) }
        end
      else
        set_flash_message!(:error)
        options = { :with => object.errors, :status => :unprocessable_entity }

        respond_to_with_dual_blocks(false, respond_block, options) do |format|
          format.html { render :action => 'new' }
        end
      end
    end
    alias :create! :create

    # PUT /resources/1
    def update(redirect_url=nil, &block)
      object = resource
      respond_block, redirect_block = select_block_by_arity(block)

      if object.update_attributes(params[resource_instance_name])
        set_flash_message!(:notice, '{{resource_name}} was successfully updated.')

        respond_to_with_dual_blocks(true, block) do |format|
          format.html { redirect_to(redirect_block ? redirect_block.call : resource_url) }
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
    def destroy(redirect_url=nil, &block)
      resource.destroy
      respond_block, redirect_block = select_block_by_arity(block)

      set_flash_message!(:notice, '{{resource_name}} was successfully destroyed.')

      respond_to_with_dual_blocks(nil, respond_block) do |format|
        format.html { redirect_to(redirect_block ? redirect_block.call : collection_url) }
        format.all  { head :ok }
      end
    end
    alias :destroy! :destroy

    # Make aliases protected
    protected :index!, :show!, :new!, :create!, :edit!, :update!, :destroy!

  end
end
