# frozen_string_literal: true
require 'test_helper'

class Malarz
  def self.human_name; 'Painter'; end

  def to_param
    self.slug
  end
end

class PaintersController < InheritedResources::Base
  defaults instance_name: 'malarz', collection_name: 'malarze',
           resource_class: Malarz, route_prefix: nil,
           finder: :find_by_slug
end

class DefaultsTest < ActionController::TestCase
  tests PaintersController

  def setup
    draw_routes do
      resources :painters
    end
  end

  def teardown
    clear_routes
  end

  def test_expose_all_painters_as_instance_variable
    Malarz.expects(:scoped).returns([mock_painter])
    get :index

    assert_equal [mock_painter], assigns(:malarze)
  end

  def test_collection_instance_variable_should_not_be_set_if_already_defined
    @controller.instance_variable_set(:@malarze, [mock_painter])
    Malarz.expects(:scoped).never
    get :index

    assert_equal [mock_painter], assigns(:malarze)
  end

  def test_expose_the_requested_painter_on_show
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    get :show, params: { id: 'forty_two' }

    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_new_painter
    Malarz.expects(:new).returns(mock_painter)
    get :new

    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_the_requested_painter_on_edit
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    get :edit, params: { id: 'forty_two' }

    assert_response :success
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_newly_create_painter_when_saved_with_success
    Malarz.expects(:new).with(build_parameters({'these' => 'params'})).returns(mock_painter(save: true))
    post :create, params: { malarz: {these: 'params'} }

    assert_equal mock_painter, assigns(:malarz)
  end

  def test_update_the_requested_object
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    mock_painter.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: 'forty_two', malarz: {these: 'params'} }

    assert_equal mock_painter, assigns(:malarz)
  end

  def test_the_requested_painter_is_destroyed
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    mock_painter.expects(:destroy)
    delete :destroy, params: { id: 'forty_two' }

    assert_equal mock_painter, assigns(:malarz)
  end

  protected

    def mock_painter(stubs={})
      @mock_painter ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class Lecturer
  def self.human_name; 'Einstein'; end
end
module University; end
class University::LecturersController < InheritedResources::Base
  defaults finder: :find_by_slug
end

class DefaultsNamespaceTest < ActionController::TestCase
  tests University::LecturersController

  def setup
    draw_routes do
      namespace :university do
        resources :lecturers
      end
    end
  end

  def teardown
    clear_routes
  end

  def test_expose_all_lecturers_as_instance_variable
    Lecturer.expects(:scoped).returns([mock_lecturer])
    get :index

    assert_equal [mock_lecturer], assigns(:lecturers)
  end

  def test_expose_the_requested_lecturer_on_show
    Lecturer.expects(:find_by_slug).with('forty_two').returns(mock_lecturer)
    get :show, params: { id: 'forty_two' }

    assert_equal mock_lecturer, assigns(:lecturer)
  end

  def test_expose_a_new_lecturer
    Lecturer.expects(:new).returns(mock_lecturer)
    get :new

    assert_equal mock_lecturer, assigns(:lecturer)
  end

  def test_expose_the_requested_lecturer_on_edit
    Lecturer.expects(:find_by_slug).with('forty_two').returns(mock_lecturer)
    get :edit, params: { id: 'forty_two' }

    assert_response :success
    assert_equal mock_lecturer, assigns(:lecturer)
  end

  def test_expose_a_newly_create_lecturer_when_saved_with_success
    Lecturer.expects(:new).with(build_parameters({'these' => 'params'})).returns(mock_lecturer(save: true))
    post :create, params: { lecturer: {these: 'params'} }

    assert_equal mock_lecturer, assigns(:lecturer)
  end

  def test_update_the_lecturer
    Lecturer.expects(:find_by_slug).with('forty_two').returns(mock_lecturer)
    mock_lecturer.expects(:update).with(build_parameters({'these' => 'params'})).returns(true)
    put :update, params: { id: 'forty_two', lecturer: {these: 'params'} }

    assert_equal mock_lecturer, assigns(:lecturer)
  end

  def test_the_requested_lecturer_is_destroyed
    Lecturer.expects(:find_by_slug).with('forty_two').returns(mock_lecturer)
    mock_lecturer.expects(:destroy)
    delete :destroy, params: { id: 'forty_two' }

    assert_equal mock_lecturer, assigns(:lecturer)
  end

  protected

    def mock_lecturer(stubs={})
      @mock_lecturer ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end

class Group
end
class AdminGroup
end
module Admin; end
class Admin::Group
end
class Admin::GroupsController < InheritedResources::Base
end
class NamespacedModelForNamespacedController < ActionController::TestCase
  tests Admin::GroupsController

  def test_that_it_picked_the_namespaced_model
    # make public so we can test it
    Admin::GroupsController.send(:public, :resource_class)

    assert_equal Admin::Group, @controller.resource_class
  end
end

class Role
end
class AdminRole
end
class Admin::RolesController < InheritedResources::Base
end
class TwoPartNameModelForNamespacedController < ActionController::TestCase
  tests Admin::RolesController

  def test_that_it_picked_the_camelcased_model
    # make public so we can test it
    Admin::RolesController.send(:public, :resource_class)

    assert_equal AdminRole, @controller.resource_class
  end
end

class User
end
class Admin::UsersController < InheritedResources::Base
end
class AnotherTwoPartNameModelForNamespacedController < ActionController::TestCase
  tests Admin::UsersController

  def test_that_it_picked_the_camelcased_model
    # make public so we can test it
    Admin::UsersController.send(:public, :resource_class)

    assert_equal User, @controller.resource_class
  end

  def test_that_it_got_the_request_params_right
    # make public so we can test it
    Admin::UsersController.send(:public, :resources_configuration)

    assert_equal 'user', @controller.resources_configuration[:self][:request_name]
  end
end

module MyEngine
  class Engine < Rails::Engine
    isolate_namespace MyEngine
  end

  class Person
    extend ActiveModel::Naming
  end

  class PeopleController < InheritedResources::Base
    defaults resource_class: Person
  end
end

class IsolatedEngineModelController < ActionController::TestCase
  tests MyEngine::PeopleController

  def setup
    # make public so we can test it
    MyEngine::PeopleController.send(:public, *MyEngine::PeopleController.protected_instance_methods)
  end

  def test_isolated_model_name
    assert_equal 'person', @controller.resources_configuration[:self][:request_name]
  end
end
