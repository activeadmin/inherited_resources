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
module InheritedResources #:nodoc:
  module UrlHelpers #:nodoc:

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

      # Deal with belongs_to associations.
      #
      # If we find a :polymorphic symbol, it means that we should not add
      # :route_name to resource_segments (which will be useless anyway).
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
      # We define collection_url to singletons just for compatibility mode.
      #
      # The collection_url for singleton is the parent show url. For example,
      # if we have ProjectsController with ManagerController, where the second
      # is the singleton, the collection url would be: project_url.
      #
      # This is where you are going to be redirected after destroing the manager.
      #
      unless base.singleton
        resource_segments << resource_config[:collection_name] 
        generate_url_and_path_helpers(base, nil, :collection, resource_segments, resource_ivars, polymorphic)
        resource_segments.pop
      else
        generate_url_and_path_helpers(base, nil, :collection, resource_segments, resource_ivars, polymorphic)
      end

      # Prepare and add new_resource_url
      resource_segments << resource_config[:instance_name]
      generate_url_and_path_helpers(base, :new, :resource, resource_segments, resource_ivars, polymorphic)

      # We don't add the resource ivar to edit and resource url if singleton
      resource_ivars << resource_config[:instance_name] unless base.singleton

      # Prepare and add resource_url and edit_resource_url
      generate_url_and_path_helpers(base, nil, :resource, resource_segments, resource_ivars, polymorphic)
      generate_url_and_path_helpers(base, :edit, :resource, resource_segments, resource_ivars, polymorphic)
    end

    def self.generate_url_and_path_helpers(base, prefix, name, resource_segments, resource_ivars, polymorphic=false)
        ivars = resource_ivars.map{|i| i == :parent ? :parent : "@#{i}" }

        # If it's not a singleton, ivars are not empty, not a collection or
        # not a new hew helper, we can add args to the method.
        #
        arg = unless base.singleton || ivars.empty? || name == :collection || prefix == :new
          ivars.push("(given_arg || #{ivars.pop})")
          'given_arg=nil'
        else
          ''
        end

        # When polymorphic is true, the segments must be replace by :polymorphic
        # and ivars should be gathered into an array.
        #
        if polymorphic
          segments = :polymorphic

          # Customization to allow polymorphic with singletons.
          #
          # In such cases, we must send a string with the resource instance name
          # to polymorphic_url.
          #
          # When not a singleton, but a collection or new url, we should add
          # resource_class.new to instance ivars to allow polymorphic_url to
          # deal with it properly.
          #
          if base.singleton
            ivars << base.resources_configuration[:self][:instance_name].inspect unless name == :collection
          elsif name == :collection || prefix == :new
            ivars << 'resource_class.new'
          end

          ivars  = "[#{ivars.join(', ')}]"
        else
          segments = resource_segments.join('_')
          ivars    = ivars.join(', ')
        end

        prefix   = prefix ? "#{prefix}_" : ''

        base.class_eval <<URL_HELPERS, __FILE__, __LINE__
protected
  def #{prefix}#{name}_path(#{arg})
    #{prefix}#{segments}_path(#{ivars})
  end

  def #{prefix}#{name}_url(#{arg})
    #{prefix}#{segments}_url(#{ivars})
  end
URL_HELPERS
    end

  end
end
