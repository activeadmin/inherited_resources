# Changelog

## Master (unreleased)

* Remove support for Ruby `< 2.5`.
* Coerce `:route_prefix` config option to a Symbol, ensuring compatibility with Rails versions that have resolved CVE-2021-22885.

## Version 1.12.0

* Remove support for Rails 5.0 and Rails 5.1.
* Allow using Rails 6.1.

## Version 1.11.0

* Add support for responders `>= 3.0`.
* Remove support for Ruby `< 2.4`.

## Version 1.10.0

_No changes_.

## Version 1.10.0.rc1

* Preliminary support for Rails 6.0.
* Remove support for Rails 4.2.

## Version 1.9.0

* Support Rails 5.2.1.
* Remove support for Ruby `< 2.3`.

## Version 1.8.0

* Support Rails 5.2.
* Supports Ruby 2.4.
* Remove support for Ruby `< 2.2`, and Rails `< 4.2`.
* Fixed broken class name in belongs_to.
* Remove use of HttpCacheResponder.
* Correct request_name in isolated engines.
* Fix nested controllers and singleton option.

## Version 1.7.2

* Support Rails 5.1.

## Version 1.7.1

* Fix regression with `get_resource_ivar` that was returning `false` instead of `nil` when the value was not set.
* Do not load `ActionController::Base` on boot time.

## Version 1.7.0

* Support Rails 5.
* Remove support for Ruby `< 2.1`.
* Fix URL helpers on mountable engines.
* Allow support to has_scope `< 0.6` and `> 1.0`. Users are now able to choose which version they want to use in their applications.

## Version 1.6.0

* Support Rails 4.2.

## Version 1.5.1

* Lock the Rails version until only 4.2.
* Fix parent class lookup.
* Fix resource_class default value definition.

## Version 1.5.0

* Supports nested modules (namespaced models and controllers).
* Supports Rails 4 Strong Parameters notation.

## Version 1.4.1

* Supports Rails 4.
* Improved compatability with strong params.

## Version 1.4.0

* Supports Ruby 2.0.0.
* Added support for the strong_parameters gem. See the README for more.
* Added the ability to pass without_protection when creating/updating.
* Fixed multi-level nested singletons.
* Correct paths now generated for uncountable shallow resources.

## Version 1.3.1

* Fix polymorphic_belongs_to to get the parent.
* Added support for Rails 3.2.
* Added support to responders >= 0.6.0.

## Version 1.3.0

* Added support for multiple polymorphic optional nesting.
* Fix nested namespace in mountable apps.
* Added support for rails 3.1 new mass assignment conventions.
* Turn InheritedResources::Base into a reloadable constant to fix reloading issues.

## Version 1.2.2

* Fix a bug in params parsing.
* Call .scoped only if it is available.

## Version 1.2.1

* Fix a bug with namespaces.
* Use Post.scoped instead of Post.all in collection.

## Version 1.2

* Improved lookup for namespaces (by github.com/Sirupsen).
* Support to custom actions (by github.com/lda).
* Rails 3.1 compatibility (by github.com/etehtsea).

## Version 1.1

* Rails 3 compatible.

## Version 1.0

* responders was removed from InheritedResources core and is a dependency. To install it, please do:

    sudo gem install responders

* has_scope was removed from InheritedResources core and is now available as a standalone gem.

  To install it, please do:

    sudo gem install has_scope

## Version 0.9

* Allow dual blocks in destroy.
* Added :if and :unless to has_scope (thanks to Jack Danger).
* Added create_resource, update_resource and delete_resource hooks (thanks to Carlos Antonio da Silva).
* Backported ActionController::Responder from Rails 3.
* Added parent_url helper.
* Added association_chain helper (as suggested by http://github.com/emmanuel).

## Version 0.8

* Fixed a small bug on optional belongs to with namespaced controllers.
* Allow a parameter to be given to collection_url in polymorphic cases to replace the parent.
* Allow InheritedResources to be called without inheritance.
* Ensure that controllers that inherit from a controller with InheritedResources works properly.

## Version 0.7

* Allow procs as default value in has scope to be able to use values from session, for example.
* Allow blocks with arity 0 or -1 to be given as the redirect url:

    def destroy
      destroy!{ project_url(@project) }
    end

* Allow interpolation_options to be set in the application controller.
* Added has_scope to controller (an interface for named_scopes).
* Added polymorphic_belongs_to, optional_belongs_to and singleton_belongs_to as quick methods.
* Only load belongs_to, singleton and polymorphic helpers if they are actually required. base_helpers, class_methods, dumb_responder and url_helpers are loaded when you inherited from base for the first time.

# Version 0.6

* Ensure that the default template is not rendered if the default_template_format is not accepted. This is somehow related with the security breach report:

  http://www.rorsecurity.info/journal/2009/4/24/hidden-actions-render-templates.html

  IR forbids based on mime types. For example: respond_to :html, :except => :index ensures that the index.html.erb view is not rendered, making your IR controllers safer.

* Fixed a bug that happens only when format.xml is given to blocks and then it acts as default, instead of format.html.
* Fixed a strange bug where when you have create.html.erb or update.html.erb, it makes IE6 and IE7 return unprocessable entity (because they send Mime::ALL).
* Stop rescueing any error when constantizing the resource class and allow route_prefix to be nil.
* Cleaned up tests and responder structure. Whenever you pass a block to aliases and this block responds to the request, the other blocks are not parsed improving performance.
* [BACKWARDS INCOMPATIBLE] By default, Inherited Resources respond only :html requests.
* Added a quick way to overwrite the redirect to url in :create, :update and :destroy.

## Version 0.5

* Decoupled routes name from :instance_name and :collection_name. This way we have more flexibility. Use route_instance_name and route_collection_name to to change routes.
* Avoid calling human_name on nil when a resource class is not defined.
* Only call I18n if it's defined.

## Version 0.4

* Dealing with namespaced controllers out of the box.
* Added support to namespaced routes through :route_prefix.
* Added fix when resource_url is not defined.
* Added better handling for namespaced controllers.
* Added flash messages scoped by namespaced controllers.
* Deprecated {{resource}} in I18n, use {{resource_name}} instead.
* rspec bug fix is not automatically required anymore. User has to do it explicitly.
* Added a file which fix a rspec bug when render is called inside a method which receives a block.
* parent? does not take begin_of_association_chain into account anymore.
* Added options to url helpers.
* Added :optional to belongs_to associations. It allows you to deal with categories/1/products/2 and /products/2 with just one controller.
* Cleaned up tests.

## Version 0.3

* Minor bump after three bug fixes.
* Bug fix when showing warning of constant redefinition.
* Bug fix with ApplicationController not being unloaded properly on development.
* Bug fix when having root singleton resources. Calling `collection_url` would raise "NoMethodError \_url", not it will call root_url.
* More comments on UrlHelpers.

## Version 0.2

* Bug fix when ApplicationController is already loaded when we load respond_to.
* Added support success/failure blocks.
* Eager loading of files to work properly in multithreaded environments.

## Version 0.1

* Added more helper_methods.
* Added Rails 2.3.0 and changed tests to work with ActionController::TestCase.
* First release. Support to I18n, singleton controllers, polymorphic controllers, belongs_to, nested_belongs_to and url helpers.
