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
  #
  #  # /projects/1/tasks
  #  resource_url          # => /products/1/tasks/#{@task.to_param}
  #  resource_url(task)    # => /products/1/tasks/#{task.to_param}
  #  new_resource_url      # => /products/1/tasks/new
  #  edit_resource_url     # => /products/1/tasks/#{@task.to_param}/edit
  #  collection_url        # => /products/1/tasks
  #
  #  # /users
  #  resource_url          # => /users/#{@user.to_param}
  #  resource_url(user)    # => /users/#{user.to_param}
  #  new_resource_url      # => /users/new
  #  edit_resource_url     # => /users/#{@user.to_param}/edit
  #  collection_url        # => /users
  #
  # The nice thing is that those urls are not guessed during runtime. They are
  # all created when you inherit.
  #
  module UrlHelpers

    # This method hard code url helpers in the class.
    #
    # We are doing this because is cheaper than guessing them when our action
    # is being processed (and even more cheaper when we are using nested
    # resources).
    #
    # When we are using polymorphic associations, those helpers rely on 
    # polymorphic_url Rails helper.
    #
    def self.create_resources_url_helpers!(base)
      resource_segments, resource_ivars = [], []
      resource_config = base.resources_configuration[:self]
      polymorphic = false

      # Add route_prefix if any.
      resource_segments << resource_config[:route_prefix] unless resource_config[:route_prefix].blank?

      # Deal with belongs_to associations and polymorphic associations.
      # Remember that we don't have to build the segments in polymorphic cases,
      # because the url will be polymorphic_url.
      #
      base.parents_symbols.map do |symbol|
        if symbol == :polymorphic
          polymorphic = true
          resource_ivars << :parent
        else
          config = base.resources_configuration[symbol]
          resource_segments << config[:route_name]
          resource_ivars    << config[:instance_name]
        end
      end

      # Deals with singleton.
      #
      # If not a singleton, we add the current collection name and build the
      # collection url. It can build for example:
      #
      #   project_tasks_url
      #
      # If it's a singleton we also build a collection, just for compatibility.
      # The collection_url for singleton is the parent show url. For example,
      # if we have ProjectsController with ManagerController, where the second
      # is the singleton, the collection url would be: project_url(@project).
      #
      # This is where you are going to be redirected after destroying the manager.
      #
      unless base.singleton
        resource_segments << resource_config[:route_collection_name]
        generate_url_and_path_helpers(base, nil, :collection, resource_segments, resource_ivars, polymorphic)
        resource_segments.pop
      else
        generate_url_and_path_helpers(base, nil, :collection, resource_segments, resource_ivars, polymorphic)
      end

      # Prepare and add new_resource_url
      resource_segments << resource_config[:route_instance_name]
      generate_url_and_path_helpers(base, :new, :resource, resource_segments, resource_ivars, polymorphic)

      # We don't add the resource_ivar to edit and show url if singleton.
      # Singletons are simply:
      #
      #   edit_project_manager_url(@project)
      #
      # Instead of:
      #
      #   edit_project_manager_url(@project, @manager)
      #
      resource_ivars << resource_config[:instance_name] unless base.singleton

      # Prepare and add resource_url and edit_resource_url
      generate_url_and_path_helpers(base, nil, :resource, resource_segments, resource_ivars, polymorphic)
      generate_url_and_path_helpers(base, :edit, :resource, resource_segments, resource_ivars, polymorphic)
    end

    def self.generate_url_and_path_helpers(base, prefix, name, resource_segments, resource_ivars, polymorphic=false) #:nodoc:
        ivars = resource_ivars.map{|i| i == :parent ? :parent : "@#{i}" }

        # If it's not a singleton, ivars are not empty, not a collection or
        # not a "new" named route, we can pass a resource as argument.
        #
        unless base.singleton || ivars.empty? || name == :collection || prefix == :new
          ivars.push "(given_args.first || #{ivars.pop})"
        end

        # When polymorphic is true, the segments must be replace by :polymorphic
        # and ivars should be gathered into an array.
        #
        if polymorphic
          segments = :polymorphic

          # Customization to allow polymorphic with singletons.
          #
          # Let's take the projects and companies where each one has one manager
          # example. The url helpers would be:
          #
          #   company_manager_url(@company)
          #   project_manager_url(@project)
          #
          # Notice how the manager is not sent in the helper, because it's a
          # singleton. So, polymorphic urls would be:
          #
          #   polymorphic_url(@company)
          #   polymorphic_url(@project)
          #
          # Obviously, this won't work properly. So in such polymorphic with
          # singletons cases we have to do this:
          #
          #   polymorphic_url(@company, 'manager')
          #   polymorphic_url(@project, 'manager')
          #
          # This is exactly what we are doing here.
          #
          # The other case to handle is collection and new helpers with
          # polymorphic urls. In such cases, we usually would not send anything:
          #
          #   project_tasks_url(@project)
          #   new_project_task_url(@project)
          #
          # But this wouldn't work with polymorphic urls by the same reason as
          # singletons:
          #
          #   polymorphic_url(@project)
          #   new_polymorphic_url(@project)
          #
          # So we have to do this:
          #
          #   polymorphic_url(@project, Task.new)
          #   new_polymorphic_url(@project, Task.new)
          #
          if base.singleton
            ivars << base.resources_configuration[:self][:instance_name].inspect unless name == :collection
          elsif name == :collection || prefix == :new
            ivars << 'resource_class.new'
          end

          ivars  = "[#{ivars.join(', ')}]"

          # Add compact to deal with polymorphic optional associations.
          ivars << '.compact' if base.resources_configuration[:polymorphic][:optional]
        else
          # In the last case, if segments is empty (this usually happens with
          # root singleton resources, we set it to root)
          #
          segments = resource_segments.empty? ? 'root' : resource_segments.join('_')
          ivars    = ivars.join(', ')
        end

        prefix = prefix ? "#{prefix}_" : ''

        # Add given_options to ivars
        ivars << (ivars.empty? ? 'given_options' : ', given_options')

        base.class_eval <<URL_HELPERS, __FILE__, __LINE__
protected
  def #{prefix}#{name}_path(*given_args)
    given_options = given_args.extract_options!
    #{prefix}#{segments}_path(#{ivars})
  end

  def #{prefix}#{name}_url(*given_args)
    given_options = given_args.extract_options!
    #{prefix}#{segments}_url(#{ivars})
  end
URL_HELPERS
    end

  end
end
