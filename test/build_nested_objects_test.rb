require File.expand_path('test_helper', File.dirname(__FILE__))

class Notebook; extend ActiveModel::Naming end

class NotebooksController < InheritedResources::Base; end

class BuildNetstedObjectsTest < ActionController::TestCase

  tests NotebooksController

  def setup
    @controller.stubs(:resource_url).returns('/')
    @controller._routes.url_helpers.stubs("hash_for_notebook_url").returns({:no=>"no"})
    Notebook.stubs(:new).returns(mock_notebook)
    Notebook.stubs(:find).with(1).returns(mock_notebook)
    mock_notebook.stubs(:components).returns(mock_components)
  end

  def test_build_producer_on_new_action
    setup_producer
    mock_notebook.expects(:build_producer)
    mock_notebook.expects(:producer).returns(nil)
    get :new
  end

  def test_not_build_producer_on_create_action_with_valid_params
    setup_producer
    mock_notebook.unstub(:build_producer)
    mock_notebook.expects(:save).returns(true)
    post :create, :notebook => {:these => 'params'}
  end

  def test_build_producer_on_create_action_with_invalid_params
    setup_producer
    mock_notebook.expects(:producer).returns(nil)
    mock_notebook.expects(:build_producer)
    mock_notebook.expects(:save).returns(false)
    post :create, :notebook => {:these => 'params'}
  end

  def test_build_producer_on_edit_when_producer_not_exists
    setup_producer
    mock_notebook.expects(:producer).returns(nil)
    mock_notebook.expects(:build_producer)
    get :edit, :id => 1
  end

  def test_not_build_producer_on_edit_when_producer_exists
    setup_producer
    mock_notebook.expects(:producer).returns(mock_producer)
    mock_notebook.unstub(:build_producer)
    get :edit, :id => 1
  end

  def test_not_build_producer_on_update_action_with_valid_params_when_producer_not_exists
    setup_producer
    mock_notebook.unstub(:build_producer)
    mock_notebook.expects(:update_attributes).returns(true)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_not_build_producer_on_update_action_with_valid_params_when_producer_exists
    setup_producer
    mock_notebook.stubs(:producer).returns(mock_producer)
    mock_notebook.unstub(:build_producer)
    mock_notebook.expects(:update_attributes).returns(true)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_build_producer_on_update_action_with_invalid_params_when_producer_not_exists
    setup_producer
    mock_notebook.stubs(:producer).returns(nil)
    mock_notebook.expects(:build_producer)
    mock_notebook.expects(:update_attributes).returns(false)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_not_build_producer_on_update_action_with_invalid_params_when_producer_exists
    setup_producer
    mock_notebook.stubs(:producer).returns(mock_producer)
    mock_notebook.unstub(:build_producer)
    mock_notebook.expects(:update_attributes).returns(false)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_build_components_on_new_action
    setup_components
    mock_components.expects(:build)
    get :new
  end

  def test_not_build_components_on_create_action_with_valid_params
    setup_components
    mock_components.unstub(:build)
    mock_notebook.expects(:save).returns(true)
    post :create, :notebook => {:these => 'params'}
  end

  def test_build_components_on_create_action_with_invalid_params
    setup_components
    mock_components.expects(:build)
    mock_notebook.expects(:save).returns(false)
    post :create, :notebook => {:these => 'params'}
  end

  def test_build_components_on_edit_when_components_not_exists
    setup_components
    mock_components.expects(:build)
    get :edit, :id => 1
  end

  def test_not_build_components_on_update_action_with_valid_params
    setup_components
    mock_notebook.expects(:update_attributes).returns(true)
    mock_components.unstub(:build)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_build_components_on_update_action_with_invalid_params
    setup_components
    mock_components.expects(:build)
    mock_notebook.expects(:update_attributes).returns(false)
    put :update, :id => 1, :notebook => {:these => 'params'}
  end

  def test_build_all_nested_objects
    Notebook.expects(:nested_attributes_options).returns({:producer => "producer options", :components => "component options"})
    NotebooksController.send :build_nested_objects_for, :all
    mock_notebook.expects(:producer).returns(nil)
    mock_components.expects(:build)
    mock_notebook.expects(:build_producer)
    get :new
  end

  protected

    def setup_producer
      NotebooksController.send :build_nested_objects_for, :producer
    end

    def setup_components
      NotebooksController.send :build_nested_objects_for, :components
    end

    def mock_producer
      @mock_producer ||= mock({})
    end

    def mock_components
      @mock_components ||= begin
                            components = mock({})
                            components.stubs(:is_a?).with(Array).returns(true)
                            components.stubs(:build)
                            components
                           end
    end

    def mock_notebook(stubs={})
      @mock_notebook ||= begin
                           notebook = mock(stubs)
                           notebook.stubs(:class).returns(Notebook)
                           notebook
                         end
    end
end
