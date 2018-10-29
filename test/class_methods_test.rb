require 'test_helper'

class Book; end
class Folder; end

class BooksController < InheritedResources::Base
  custom_actions collection: :search, resource: [:delete]
  actions :index, :show
end

class ReadersController < InheritedResources::Base
  actions :all, except: [ :edit, :update ]
end

class FoldersController < InheritedResources::Base
end

class Dean
  def self.human_name; 'Dean'; end
end

class DeansController < InheritedResources::Base
  belongs_to :school
end

module Controller
  class User; end

  class UsersController < InheritedResources::Base; end

  module Admin
    class UsersController < InheritedResources::Base; end
  end
end

class ControllerGroup; end

module Controller
  class GroupsController < InheritedResources::Base; end
end

module Library
  class Base
  end

  class Category
  end

  class Subcategory
  end

  class SubcategoriesController < InheritedResources::Base
  end
end

module MyEngine
  class Engine < Rails::Engine
    isolate_namespace MyEngine
  end

  class PeopleController < InheritedResources::Base; end
end

module MyNamespace
  class PeopleController < InheritedResources::Base; end
end

module EmptyNamespace; end

class ActionsClassMethodTest < ActionController::TestCase
  tests BooksController

  def test_cannot_render_actions
    assert_raise AbstractController::ActionNotFound do
      get :new
    end
  end

  def test_actions_are_undefined
    action_methods = BooksController.send(:action_methods).map(&:to_sym)
    assert_equal 4, action_methods.size

    [:index, :show, :delete, :search].each do |action|
      assert action_methods.include?(action)
    end

    instance_methods = BooksController.send(:instance_methods).map(&:to_sym)

    [:new, :edit, :create, :update, :destroy].each do |action|
      assert !instance_methods.include?(action)
    end
  end

  def test_actions_are_undefined_when_except_option_is_given
    action_methods = ReadersController.send(:action_methods)
    assert_equal 5, action_methods.size

    ['index', 'new', 'show', 'create', 'destroy'].each do |action|
      assert action_methods.include? action
    end
  end
end

class DefaultsClassMethodTest < ActiveSupport::TestCase
  def test_resource_class_is_set_to_nil_when_resource_model_cannot_be_found
    assert_nil ReadersController.send(:resource_class)
  end

  def test_defaults_are_set
    assert_equal Folder, FoldersController.send(:resource_class)
    assert_equal :folder, FoldersController.send(:resources_configuration)[:self][:instance_name]
    assert_equal :folders, FoldersController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_can_be_overwriten
    BooksController.send(:defaults, resource_class: String, instance_name: 'string', collection_name: 'strings')

    assert_equal String, BooksController.send(:resource_class)
    assert_equal :string, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert_equal :strings, BooksController.send(:resources_configuration)[:self][:collection_name]

    BooksController.send(:defaults, class_name: 'Fixnum', instance_name: :fixnum, collection_name: :fixnums)

    assert_equal Fixnum, BooksController.send(:resource_class)
    assert_equal :fixnum, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert_equal :fixnums, BooksController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_raises_invalid_key
    assert_raise ArgumentError do
      BooksController.send(:defaults, boom: String)
    end
  end

  def test_url_helpers_are_recreated_when_defaults_change
    BooksController.expects(:create_resources_url_helpers!).returns(true).once
    BooksController.send(:defaults, instance_name: 'string', collection_name: 'strings')
  end
end

class BelongsToErrorsTest < ActiveSupport::TestCase
  def test_belongs_to_raise_errors_with_invalid_arguments
    assert_raise ArgumentError do
      DeansController.send(:belongs_to)
    end

    assert_raise ArgumentError do
      DeansController.send(:belongs_to, :nice, invalid_key: '')
    end
  end

  def test_belongs_to_raises_an_error_when_multiple_associations_are_given_with_options
    assert_raise ArgumentError do
      DeansController.send(:belongs_to, :arguments, :with_options, parent_class: Book)
    end
  end

  def test_url_helpers_are_recreated_just_once_when_belongs_to_is_called_with_block
    DeansController.expects(:create_resources_url_helpers!).returns(true).once
    DeansController.send(:belongs_to, :school) do
      belongs_to :association
    end
  ensure
    DeansController.send(:parents_symbols=, [:school])
  end

  def test_url_helpers_are_recreated_just_once_when_belongs_to_is_called_with_multiple_blocks
    DeansController.expects(:create_resources_url_helpers!).returns(true).once
    DeansController.send(:belongs_to, :school) do
      belongs_to :association do
        belongs_to :nested
      end
    end
  ensure
    DeansController.send(:parents_symbols=, [:school])
  end

  def test_belongs_to_for_namespaced_controller_and_namespaced_model_fetches_model_in_the_namespace_firstly
    Library::SubcategoriesController.send(:belongs_to, :category)
    assert_equal Library::Category, Library::SubcategoriesController.resources_configuration[:category][:parent_class]
  end

  def test_belongs_to_for_namespaced_controller_and_non_namespaced_model_sets_parent_class_properly
    Library::SubcategoriesController.send(:belongs_to, :book)
    assert_equal Book, Library::SubcategoriesController.resources_configuration[:book][:parent_class]
  end

  def test_belongs_to_for_namespaced_model_sets_parent_class_properly
    Library::SubcategoriesController.send(:belongs_to, :library, class_name: 'Library::Base')
    assert_equal Library::Base, Library::SubcategoriesController.resources_configuration[:library][:parent_class]
  end

  def test_belongs_to_without_namespace_sets_parent_class_properly
    FoldersController.send(:belongs_to, :book)
    assert_equal Book, FoldersController.resources_configuration[:book][:parent_class]
  end
end

class SpecialCasesClassMethodTest < ActionController::TestCase
  def test_resource_class_to_corresponding_model_class
    assert_equal Controller::User, Controller::UsersController.send(:resource_class)
    assert_equal Controller::User, Controller::Admin::UsersController.send(:resource_class)
    assert_equal ControllerGroup, Controller::GroupsController.send(:resource_class)
  end
end

class MountableEngineTest < ActiveSupport::TestCase
  def test_route_prefix_do_not_include_engine_name
    puts MyEngine::PeopleController.send(:resources_configuration)[:self][:route_prefix]
    assert_nil MyEngine::PeopleController.send(:resources_configuration)[:self][:route_prefix]
  end

  def test_route_prefix_present_when_parent_module_is_not_a_engine
    assert_equal 'my_namespace', MyNamespace::PeopleController.send(:resources_configuration)[:self][:route_prefix]
  end
end

class EngineLoadErrorTest < ActiveSupport::TestCase
  def test_does_not_crash_on_engine_load_error
    ActiveSupport::Dependencies.autoload_paths << 'test/autoload'

    EmptyNamespace.class_eval <<-RUBY
      class PeopleController < InheritedResources::Base; end
    RUBY
  end
end
