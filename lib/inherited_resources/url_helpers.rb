module InheritedResources
  # = URLHelpers
  #
  # When you use InheritedResources it creates some UrlHelpers for you.
  # And they handle everything for you.
  #
  #  # /posts/1/comments
  #  resource_url          # => /posts/1/comments/#{@comment.to_param}
  #  resource_url(comment) # => /posts/1/comments/#{comment.to_param}
  #  new_resource_url      # => /posts/1/comments/new
  #  edit_resource_url     # => /posts/1/comments/#{@comment.to_param}/edit
  #  collection_url        # => /posts/1/comments
  #  parent_url            # => /posts/1
  #
  #  # /projects/1/tasks
  #  resource_url          # => /projects/1/tasks/#{@task.to_param}
  #  resource_url(task)    # => /projects/1/tasks/#{task.to_param}
  #  new_resource_url      # => /projects/1/tasks/new
  #  edit_resource_url     # => /projects/1/tasks/#{@task.to_param}/edit
  #  collection_url        # => /projects/1/tasks
  #  parent_url            # => /projects/1
  #
  #  # /users
  #  resource_url          # => /users/#{@user.to_param}
  #  resource_url(user)    # => /users/#{user.to_param}
  #  new_resource_url      # => /users/new
  #  edit_resource_url     # => /users/#{@user.to_param}/edit
  #  collection_url        # => /users
  #  parent_url            # => /
  #
  # The nice thing is that those urls are not guessed during runtime. They are
  # all created when you inherit.
  #
  module UrlHelpers
    protected

    # This method hard code url helpers in the class.
    #
    # We are doing this because is cheaper than guessing them when our action
    # is being processed (and even more cheaper when we are using nested
    # resources).
    #
    # When we are using polymorphic associations, those helpers rely on
    # polymorphic_url Rails helper.
    #
    def create_resources_url_helpers!
      resource_segments, resource_ivars = [], []
      resource_config = self.resources_configuration[:self]

      singleton   = resource_config[:singleton]
      uncountable = !singleton && resource_config[:route_collection_name] == resource_config[:route_instance_name]
      polymorphic = self.parents_symbols.include?(:polymorphic)

      # Add route_prefix if any.
      unless resource_config[:route_prefix].blank?
        if polymorphic
          resource_ivars << resource_config[:route_prefix].to_s
        else
          resource_segments << resource_config[:route_prefix]
        end
      end

      # Deal with belongs_to associations and polymorphic associations.
      # Remember that we don't have to build the segments in polymorphic cases,
      # because the url will be polymorphic_url.
      #
      self.parents_symbols.each do |symbol|
        if symbol == :polymorphic
          resource_ivars << :parent
        else
          config = self.resources_configuration[symbol]
          if config[:singleton] && polymorphic
            resource_ivars << config[:instance_name]
          else
            resource_segments << config[:route_name]
          end
          if !config[:singleton]
            resource_ivars    << :"@#{config[:instance_name]}"
          end
        end
      end

      collection_ivars    = resource_ivars.dup
      collection_segments = resource_segments.dup


      # Generate parent url before we add resource instances.
      unless parents_symbols.empty?
        generate_url_and_path_helpers nil,   :parent, resource_segments, resource_ivars
        generate_url_and_path_helpers :edit, :parent, resource_segments, resource_ivars
      end

      # In singleton cases, we do not send the current element instance variable
      # because the id is not in the URL. For example, we should call:
      #
      #   project_manager_url(@project)
      #
      # Instead of:
      #
      #   project_manager_url(@project, @manager)
      #
      # Another exception in singleton cases is that collection url does not
      # exist. In such cases, we create the parent collection url. So in the
      # manager case above, the collection url will be:
      #
      #    project_url(@project)
      #
      # If the singleton does not have a parent, it will default to root_url.
      #
      collection_segments << resource_config[:route_collection_name] unless singleton
      resource_segments   << resource_config[:route_instance_name]
      resource_ivars      << :"@#{resource_config[:instance_name]}" unless singleton

      # Finally, polymorphic cases we have to give hints to the polymorphic url
      # builder. This works by attaching new ivars as symbols or records.
      #
      if polymorphic && singleton
        resource_ivars << resource_config[:instance_name]
        new_ivars       = resource_ivars
      end

      # If route is uncountable then add "_index" suffix to collection index route name
      if uncountable
        collection_segments << :"#{collection_segments.pop}_index"
      end

      generate_url_and_path_helpers nil,   :collection, collection_segments, collection_ivars
      generate_url_and_path_helpers :new,  :resource,   resource_segments,   new_ivars || collection_ivars
      generate_url_and_path_helpers nil,   :resource,   resource_segments,   resource_ivars
      generate_url_and_path_helpers :edit, :resource,   resource_segments,   resource_ivars

      if resource_config[:custom_actions]
        [*resource_config[:custom_actions][:resource]].each do | method |
          generate_url_and_path_helpers method, :resource, resource_segments, resource_ivars
        end
        [*resource_config[:custom_actions][:collection]].each do | method |
          generate_url_and_path_helpers method, :resources, collection_segments, collection_ivars
        end
      end
    end

    def handle_shallow_resource(prefix, name, segments, ivars) #:nodoc:
      return segments, ivars unless self.resources_configuration[:self][:shallow]
      case name
      when :collection, :resources
        segments = segments[-2..-1]
        ivars = [ivars.last]
      when :resource
        if prefix == :new
          segments = segments[-2..-1]
          ivars = [ivars.last]
        else
          segments = [segments.last]
          ivars = [ivars.last]
        end
      when :parent
        segments = [segments.last]
        ivars = [ivars.last]
      end

      segments ||= []

      unless self.resources_configuration[:self][:route_prefix].blank?
        segments.unshift self.resources_configuration[:self][:route_prefix]
      end

      return segments, ivars
    end

    def generate_url_and_path_helpers(prefix, name, resource_segments, resource_ivars) #:nodoc:
      resource_segments, resource_ivars = handle_shallow_resource(prefix, name, resource_segments, resource_ivars)

      ivars       = resource_ivars.dup
      singleton   = self.resources_configuration[:self][:singleton]
      polymorphic = self.parents_symbols.include?(:polymorphic)

      # In collection in polymorphic cases, allow an argument to be given as a
      # replacemente for the parent.
      #
      parent_index = ivars.index(:parent) if polymorphic

      segments = if polymorphic
        :polymorphic
      elsif resource_segments.empty?
        'root'
      else
        resource_segments.join('_')
      end

      define_params_helper(prefix, name, singleton, polymorphic, parent_index, ivars)
      define_helper_method(prefix, name, :path, segments)
      define_helper_method(prefix, name, :url, segments)
    end

    def define_params_helper(prefix, name, singleton, polymorphic, parent_index, ivars)
      params_method_name = ['', prefix, name, :params].compact.join('_')

      undef_method params_method_name if method_defined? params_method_name

      define_method params_method_name do |*given_args|
        given_args = given_args.collect { |arg| arg.respond_to?(:permitted?) ? arg.to_h : arg }
        given_options = given_args.extract_options!

        args = ivars.map do |ivar|
          ivar.is_a?(Symbol) && ivar.to_s.start_with?('@') ? instance_variable_get(ivar) : ivar
        end
        args[parent_index] = parent if parent_index

        if !(singleton && name != :parent) && args.present? && name != :collection && prefix != :new
          resource = args.pop
          args.push(given_args.first || resource)
        end

        if polymorphic
          if name == :collection
            args[parent_index] = given_args.present? ? given_args.first : parent
          end
          if (name == :collection || name == :resource && prefix == :new) && !singleton
            args << (@_resource_class_new ||= resource_class.new)
          end
          args.compact! if self.resources_configuration[:polymorphic][:optional]
          args = [args]
        end
        args << given_options
      end
      protected params_method_name
    end

    def define_helper_method(prefix, name, suffix, segments)
      method_name = [prefix, name, suffix].compact.join('_')
      params_method_name = ['', prefix, name, :params].compact.join('_')
      segments_method = [prefix, segments, suffix].compact.join('_')

      undef_method method_name if method_defined? method_name

      define_method method_name do |*given_args|
        given_args = send params_method_name, *given_args
        send segments_method, *given_args
      end
      protected method_name
    end

  end
end
