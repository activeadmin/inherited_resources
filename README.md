## Notice

Inherited Resources is no longer actively maintained by the original author and
has been transferred to the ActiveAdmin organization for maintenance.  New feature
requests are not encouraged.

If you are not already using Inherited Resources we suggest instead using Rails'
`respond_with` feature alongside the [responders gem](https://github.com/plataformatec/responders).

## Inherited Resources

[![Version         ][rubygems_badge]][rubygems]
[![Github Actions  ][actions_badge]][actions]
[![Tidelift        ][tidelift_badge]][tidelift]

Inherited Resources speeds up development by making your controllers inherit
all restful actions so you just have to focus on what is important. It makes
your controllers more powerful and cleaner at the same time.

In addition to making your controllers follow a pattern, it helps you to write better
code by following fat models and skinny controllers convention. There are
two screencasts available besides this README:

* http://railscasts.com/episodes/230-inherited-resources
* http://akitaonrails.com/2009/09/01/screencast-real-thin-restful-controllers-with-inherited-resources

## Installation

You can let bundler install Inherited Resources by adding this line to your application's Gemfile:

```ruby
gem 'inherited_resources'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself with:

```sh
$ gem install inherited_resources
```

## HasScope

Since Inherited Resources 1.0, has_scope is not part of its core anymore but
a gem dependency. Be sure to check the documentation to see how you can use it:

- <http://github.com/plataformatec/has_scope>

And it can be installed as:

```sh
$ gem install has_scope
```

## Responders

Since Inherited Resources 1.0, responders are not part of its core anymore,
but is set as Inherited Resources dependency and it's used by default by
InheritedResources controllers. Be sure to check the documentation to see
how it will change your application:

- <http://github.com/plataformatec/responders>

And it can be installed with:

```sh
$ gem install responders
```

Using responders will set the flash message to :notice and :alert. You can change
that through the following configuration value:

```ruby
InheritedResources.flash_keys = [ :success, :failure ]
```

Notice the CollectionResponder won't work with InheritedResources, as
InheritedResources hardcodes the redirect path based on the current scope (like
belongs to, polymorphic associations, etc).

## Basic Usage

To use Inherited Resources you just have to inherit (duh) it:

```ruby
class ProjectsController < InheritedResources::Base
end
```

And all actions are defined and working, check it! Your projects collection
(in the index action) is still available in the instance variable `@projects`
and your project resource (all other actions) is available as `@project`.

The next step is to define which mime types this controller provides:

```ruby
class ProjectsController < InheritedResources::Base
  respond_to :html, :xml, :json
end
```

You can also specify them per action:

```ruby
class ProjectsController < InheritedResources::Base
  respond_to :html, :xml, :json
  respond_to :js, :only => :create
  respond_to :iphone, :except => [ :edit, :update ]
end
```

For each request, it first checks if the "controller/action.format" file is
available (for example "projects/create.xml") and if it's not, it checks if
the resource respond to :to_format (in this case, `:to_xml`). Otherwise returns 404.

Another option is to specify which actions the controller will inherit from
the `InheritedResources::Base`:

```ruby
class ProjectsController < InheritedResources::Base
  actions :index, :show, :new, :create
end
```

Or:

```ruby
class ProjectsController < InheritedResources::Base
  actions :all, :except => [ :edit, :update, :destroy ]
end
```

In your views, you will get the following helpers:

```ruby
resource        #=> @project
collection      #=> @projects
resource_class  #=> Project
```

As you might expect, collection (`@projects` instance variable) is only available
on index actions.

If for some reason you cannot inherit from `InheritedResources::Base`, you can
call inherit_resources in your controller class scope:

```ruby
class AccountsController < ApplicationController
  inherit_resources
end
```

One reason to use the `inherit_resources` macro would be to ensure that your controller
never responds with the html mime-type. `InheritedResources::Base` already
responds to `:html`, and the `respond_to` macro is strictly additive.
Therefore, if you want to create a controller that, for example, responds ONLY via `:js`,
you will have to write it this way:

```ruby
class AccountsController < ApplicationController
  respond_to :js
  inherit_resources
end
```

## Overwriting defaults

Whenever you inherit from InheritedResources, several defaults are assumed.
For example you can have an `AccountsController` for account management while the
resource is a `User`:

```ruby
class AccountsController < InheritedResources::Base
  defaults :resource_class => User, :collection_name => 'users', :instance_name => 'user'
end
```

In the case above, in your views you will have `@users` and `@user` variables, but
the routes used will still be `accounts_url` and `account_url`. If you plan also to
change the routes, you can use `:route_collection_name` and `:route_instance_name`.

Namespaced controllers work out of the box, but if you need to specify a
different route prefix you can do the following:

```ruby
class Administrators::PeopleController < InheritedResources::Base
  defaults :route_prefix => :admin
end
```

Then your named routes will be: `admin_people_url`, `admin_person_url` instead
of `administrators_people_url` and `administrators_person_url`.

If you want to customize how resources are retrieved you can overwrite
collection and resource methods. The first is called on index action and the
second on all other actions. Let's suppose you want to add pagination to your
projects collection:

```ruby
class ProjectsController < InheritedResources::Base
  protected
    def collection
      get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(:page => params[:page]))
    end
end
```

The `end_of_association_chain` returns your resource after nesting all associations
and scopes (more about this below).

InheritedResources also introduces another method called `begin_of_association_chain`.
It's mostly used when you want to create resources based on the `@current_user` and
you have urls like "account/projects". In such cases you have to do
`@current_user.projects.find` or `@current_user.projects.build` in your actions.

You can deal with it just by doing:

```ruby
class ProjectsController < InheritedResources::Base
  protected
    def begin_of_association_chain
      @current_user
    end
end
```

## Overwriting actions

Let's suppose that after destroying a project you want to redirect to your
root url instead of redirecting to projects url. You just have to do:

```ruby
class ProjectsController < InheritedResources::Base
  def destroy
    super do |format|
      format.html { redirect_to root_url }
    end
  end
end
```

You are opening your action and giving the parent action a new behavior. On
the other hand, I have to agree that calling super is not very readable. That's
why all methods have aliases. So this is equivalent:

```ruby
class ProjectsController < InheritedResources::Base
  def destroy
    destroy! do |format|
      format.html { redirect_to root_url }
    end
  end
end
```

Since most of the time when you change a create, update or destroy
action you do so because you want to change its redirect url, a shortcut is
provided. So you can do:

```ruby
class ProjectsController < InheritedResources::Base
  def destroy
    destroy! { root_url }
  end
end
```

If you simply want to change the flash message for a particular action, you can
pass the message to the parent action using the keys `:notice` and `:alert` (as you
would with flash):

```ruby
class ProjectsController < InheritedResources::Base
  def create
    create!(:notice => "Dude! Nice job creating that project.")
  end
end
```

You can still pass the block to change the redirect, as mentioned above:

```ruby
class ProjectsController < InheritedResources::Base
  def create
    create!(:notice => "Dude! Nice job creating that project.") { root_url }
  end
end
```

Now let's suppose that before create a project you have to do something special
but you don't want to create a before filter for it:

```ruby
class ProjectsController < InheritedResources::Base
  def create
    @project = Project.new(params[:project])
    @project.something_special!
    create!
  end
end
```

Yes, it's that simple! The nice part is since you already set the instance variable
`@project`, it will not build a project again.

Same goes for updating the project:

```ruby
class ProjectsController < InheritedResources::Base
  def update
    @project = Project.find(params[:id])
    @project.something_special!
    update!
  end
end
```

Before we finish this topic, we should talk about one more thing: "success/failure
blocks". Let's suppose that when we update our project, in case of failure, we
want to redirect to the project url instead of re-rendering the edit template.

Our first attempt to do this would be:

```ruby
class ProjectsController < InheritedResources::Base
  def update
    update! do |format|
      unless @project.errors.empty? # failure
        format.html { redirect_to project_url(@project) }
      end
    end
  end
end
```

Looks too verbose, right? We can actually do:

```ruby
class ProjectsController < InheritedResources::Base
  def update
    update! do |success, failure|
      failure.html { redirect_to project_url(@project) }
    end
  end
end
```

Much better! So explaining everything: when you give a block which expects one
argument it will be executed in both scenarios: success and failure. But if you
give a block that expects two arguments, the first will be executed only in
success scenarios and the second in failure scenarios. You keep everything
clean and organized inside the same action.

## Smart redirects

Although the syntax above is a nice shortcut, you won't need to do it frequently
because (since version 1.2) Inherited Resources has smart redirects. Redirects
in actions calculates depending on the existent controller methods.

Redirects in create and update actions calculates in the following order: `resource_url`,
`collection_url`, `parent_url` (which we are going to see later), and `root_url`. Redirect
in destroy action calculate in following order `collection_url`, `parent_url`, `root_url`.

Example:

```ruby
class ButtonsController < InheritedResources::Base
  belongs_to :window
  actions :all, :except => [:show, :index]
end
```

This controller redirect to parent window after all CUD actions.

## Success and failure scenarios on destroy

The destroy action can also fail, this usually happens when you have a
`before_destroy` callback in your model which returns false. However, in
order to tell InheritedResources that it really failed, you need to add
errors to your model. So your `before_destroy` callback on the model should
be something like this:

```ruby
def before_destroy
  if cant_be_destroyed?
    errors.add(:base, "not allowed")
    false
  end
end
```

## Belongs to

Finally, our Projects are going to get some Tasks. Then you create a
`TasksController` and do:

```ruby
class TasksController < InheritedResources::Base
  belongs_to :project
end
```

`belongs_to` accepts several options to be able to configure the association.
For example, if you want urls like "/projects/:project_title/tasks", you can
customize how InheritedResources find your projects:

```ruby
class TasksController < InheritedResources::Base
  belongs_to :project, :finder => :find_by_title!, :param => :project_title
end
```

It also accepts `:route_name`, `:parent_class` and `:instance_name` as options.
Check the [lib/inherited_resources/class_methods.rb](https://github.com/activeadmin/inherited_resources/blob/master/lib/inherited_resources/class_methods.rb)
for more.

## Nested belongs to

Now, our Tasks get some Comments and you need to nest even deeper. Good
practices says that you should never nest more than two resources, but sometimes
you have to for security reasons. So this is an example of how you can do it:

```ruby
class CommentsController < InheritedResources::Base
  nested_belongs_to :project, :task
end
```

If you need to configure any of these belongs to, you can nest them using blocks:

```ruby
class CommentsController < InheritedResources::Base
  belongs_to :project, :finder => :find_by_title!, :param => :project_title do
    belongs_to :task
  end
end
```

Warning: calling several `belongs_to` is the same as nesting them:

```ruby
class CommentsController < InheritedResources::Base
  belongs_to :project
  belongs_to :task
end
```

In other words, the code above is the same as calling `nested_belongs_to`.

## Polymorphic belongs to

We can go even further. Let's suppose our Projects can now have Files, Messages
and Tasks, and they are all commentable. In this case, the best solution is to
use polymorphism:

```ruby
class CommentsController < InheritedResources::Base
  belongs_to :task, :file, :message, :polymorphic => true
  # polymorphic_belongs_to :task, :file, :message
end
```

You can even use it with nested resources:

```ruby
class CommentsController < InheritedResources::Base
  belongs_to :project do
    belongs_to :task, :file, :message, :polymorphic => true
  end
end
```

The url in such cases can be:

```
/project/1/task/13/comments
/project/1/file/11/comments
/project/1/message/9/comments
```

When using polymorphic associations, you get some free helpers:

```ruby
parent?         #=> true
parent_type     #=> :task
parent_class    #=> Task
parent          #=> @task
```

Right now, Inherited Resources is limited and does not allow you
to have two polymorphic associations nested.

## Optional belongs to

Later you decide to create a view to show all comments, independent if they belong
to a task, file or message. You can reuse your polymorphic controller just doing:

```ruby
class CommentsController < InheritedResources::Base
  belongs_to :task, :file, :message, :optional => true
  # optional_belongs_to :task, :file, :message
end
```

This will handle all those urls properly:

```
/comment/1
/tasks/2/comment/5
/files/10/comment/3
/messages/13/comment/11
```

This is treated as a special type of polymorphic associations, thus all helpers
are available. As you expect, when no parent is found, the helpers return:

```ruby
parent?         #=> false
parent_type     #=> nil
parent_class    #=> nil
parent          #=> nil
```

## Singletons

Now we are going to add manager to projects. We say that `Manager` is a singleton
resource because a `Project` has just one manager. You should declare it as
`has_one` (or resource) in your routes.

To declare an resource of current controller  as singleton, you just have to give the
`:singleton` option in defaults.

```ruby
class ManagersController < InheritedResources::Base
  defaults :singleton => true
  belongs_to :project
  # singleton_belongs_to :project
end
```

So now you can use urls like "/projects/1/manager".

In the case of nested resources (when some of the can be singletons) you can declare it separately

```ruby
class WorkersController < InheritedResources::Base
  #defaults :singleton => true #if you have only single worker
  belongs_to :project
  belongs_to :manager, :singleton => true
end
```

This is correspond urls like "/projects/1/manager/workers/1".

It will deal with everything again and hide the action :index from you.

## Namespaced Controllers

Namespaced controllers works out the box.

```ruby
class Forum::PostsController < InheritedResources::Base
end
```

Inherited Resources prioritizes the default resource class for the namespaced controller in
this order:

```
Forum::Post
ForumPost
Post
```

## URL Helpers

When you use InheritedResources it creates some URL helpers.
And they handle everything for you. :)

```ruby
# /posts/1/comments
resource_url               # => /posts/1/comments/#{@comment.to_param}
resource_url(comment)      # => /posts/1/comments/#{comment.to_param}
new_resource_url           # => /posts/1/comments/new
edit_resource_url          # => /posts/1/comments/#{@comment.to_param}/edit
edit_resource_url(comment) # => /posts/1/comments/#{comment.to_param}/edit
collection_url             # => /posts/1/comments
parent_url                 # => /posts/1

# /projects/1/tasks
resource_url               # => /projects/1/tasks/#{@task.to_param}
resource_url(task)         # => /projects/1/tasks/#{task.to_param}
new_resource_url           # => /projects/1/tasks/new
edit_resource_url          # => /projects/1/tasks/#{@task.to_param}/edit
edit_resource_url(task)    # => /projects/1/tasks/#{task.to_param}/edit
collection_url             # => /projects/1/tasks
parent_url                 # => /projects/1

# /users
resource_url               # => /users/#{@user.to_param}
resource_url(user)         # => /users/#{user.to_param}
new_resource_url           # => /users/new
edit_resource_url          # => /users/#{@user.to_param}/edit
edit_resource_url(user)    # => /users/#{user.to_param}/edit
collection_url             # => /users
parent_url                 # => /
```

Those urls helpers also accepts a hash as options, just as in named routes.

```ruby
# /projects/1/tasks
collection_url(:page => 1, :limit => 10) #=> /projects/1/tasks?page=1&limit=10
```

In polymorphic cases, you can also give the parent as parameter to `collection_url`.

Another nice thing is that those urls are not guessed during runtime. They are
all created when your application is loaded (except for polymorphic
associations, that relies on Rails' `polymorphic_url`).

## Custom actions

Since version 1.2, Inherited Resources allows you to define custom actions in controller:

```ruby
class ButtonsController < InheritedResources::Base
  custom_actions :resource => :delete, :collection => :search
end
```

This code creates delete and search actions in controller (they behaves like show and
index actions accordingly). Also, it will produce `delete_resource_{path,url}` and
`search_resources_{path,url}` url helpers.

## What about views?

Sometimes just DRYing up the controllers is not enough. If you need to DRY up your views,
check this Wiki page:

https://github.com/activeadmin/inherited_resources/wiki/Views-Inheritance


Notice that Rails 3.1 ships with view inheritance built-in.

## Some DSL

For those DSL lovers, InheritedResources won't leave you alone. You can overwrite
your success/failure blocks straight from your class binding. For it, you just
need to add a DSL module to your application controller:

```ruby
class ApplicationController < ActionController::Base
  include InheritedResources::DSL
end
```

And then you can rewrite the last example as:

```ruby
class ProjectsController < InheritedResources::Base
  update! do |success, failure|
    failure.html { redirect_to project_url(@project) }
  end
end
```

## Strong Parameters

If your controller defines a method named `permitted_params`, InheritedResources
will call it where it would normally call params. This allows for easy
integration with the strong_parameters gem:

```ruby
def permitted_params
  params.permit(:widget => [:permitted_field, :other_permitted_field])
end
```

Remember that if your field is sent by client to server as an array, you have to write `:permitted_field => []`, not just `:permitted_field`.

Note that this doesn't work if you use strong_parameters' require method
instead of permit, because whereas permit returns the entire sanitized
parameter hash, require returns only the sanitized params below the parameter
you required.

If you need `params.require` you can do it like this:

```ruby
def permitted_params
  {:widget => params.fetch(:widget, {}).permit(:permitted_field, :other_permitted_field)}
end
```

Or better yet just override `#build_resource_params` directly:

```ruby
def build_resource_params
  [params.fetch(:widget, {}).permit(:permitted_field, :other_permitted_field)]
end
```


Instead you can stick to a standard Rails 4 notation (as rails scaffold generates) and write:

```ruby
def widget_params
  params.require(:widget).permit(:permitted_field, :other_permitted_field)
end
```

In such case you should remove #permitted_params method because it has greater priority.

## Funding

If you want to support us financially, you can [help fund the project
through a Tidelift subscription][tidelift]. By buying a Tidelift subscription
you make sure your whole dependency stack is properly maintained, while also
getting a comprehensive view of outdated dependencies, new releases, security
alerts, and licensing compatibility issues.

## Bugs and Feedback

If you discover any bugs, please describe it in the issues tracker, including Rails and InheritedResources versions.

Questions are better handled on StackOverflow.

MIT License. Copyright (c) 2009-2017 José Valim.

## Security contact information

Please use the Tidelift security contact to [report a security vulnerability][Tidelift security contact].
Tidelift will coordinate the fix and disclosure.

[rubygems_badge]: http://img.shields.io/gem/v/inherited_resources.svg
[rubygems]: https://rubygems.org/gems/inherited_resources
[actions_badge]: https://github.com/activeadmin/inherited_resources/workflows/ci/badge.svg
[actions]: https://github.com/activeadmin/inherited_resources/actions
[tidelift_badge]: https://tidelift.com/badges/github/activeadmin/inherited_resources
[tidelift]: https://tidelift.com/subscription/pkg/rubygems-inherited-resources?utm_source=rubygems-inherited-resources&utm_medium=referral&utm_campaign=readme

[Tidelift security contact]: https://tidelift.com/security
