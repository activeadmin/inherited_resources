require File.expand_path('test_helper', File.dirname(__FILE__))

if ActionPack::VERSION::MAJOR == 3
  require 'strong_parameters'
end

class Widget
  extend ActiveModel::Naming
  include ActiveModel::Conversion
end

class WidgetsController < InheritedResources::Base
end

# test usage of `permitted_params`
class StrongParametersTest < ActionController::TestCase
  def setup
    @controller = WidgetsController.new
    @controller.stubs(:widget_url).returns("/")
    @controller.stubs(:permitted_params).returns(:widget => {:permitted => 'param'})
    class << @controller
      private :permitted_params
    end
  end

  def test_permitted_params_from_new
    Widget.expects(:new).with(:permitted => 'param')
    get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_create
    Widget.expects(:new).with(:permitted => 'param').returns(mock(:save => true))
    post :create, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_update
    mock_widget = mock
    mock_widget.stubs(:class).returns(Widget)
    mock_widget.expects(:update_attributes).with(:permitted => 'param')
    mock_widget.stubs(:persisted?).returns(true)
    mock_widget.stubs(:to_model).returns(mock_widget)
    mock_widget.stubs(:model_name).returns(Widget.model_name)
    Widget.expects(:find).with('42').returns(mock_widget)
    put :update, :id => '42', :widget => {:permitted => 'param', :prohibited => 'param'}
  end

  # `permitted_params` has greater priority than `widget_params`
  def test_with_permitted_and_resource_methods
      @controller.stubs(:widget_params).returns(:permitted => 'another_param')
      class << @controller
        private :widget_params
      end
      Widget.expects(:new).with(:permitted => 'param')
      get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end
end

# test usage of `widget_params`
class StrongParametersWithoutPermittedParamsTest < ActionController::TestCase
  def setup
    @controller = WidgetsController.new
    @controller.stubs(:widget_url).returns("/")
    @controller.stubs(:widget_params).returns(:permitted => 'param')
    class << @controller
      private :widget_params
    end
  end

  def test_permitted_params_from_new
    Widget.expects(:new).with(:permitted => 'param')
    get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_create
    Widget.expects(:new).with(:permitted => 'param').returns(mock(:save => true))
    post :create, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_update
    mock_widget = mock
    mock_widget.stubs(:class).returns(Widget)
    mock_widget.expects(:update_attributes).with(:permitted => 'param')
    mock_widget.stubs(:persisted?).returns(true)
    mock_widget.stubs(:to_model).returns(mock_widget)
    mock_widget.stubs(:model_name).returns(Widget.model_name)
    Widget.expects(:find).with('42').returns(mock_widget)
    put :update, :id => '42', :widget => {:permitted => 'param', :prohibited => 'param'}
  end
end

# test usage of `widget_params` integrated with strong parameters (not using stubs)
class StrongParametersIntegrationTest < ActionController::TestCase
  def setup
    @controller = WidgetsController.new
    @controller.stubs(:widget_url).returns("/")

    class << @controller
      define_method :widget_params do
        params.require(:widget).permit(:permitted)
      end
      private :widget_params
    end
  end

  def test_permitted_empty_params_from_new
    Widget.expects(:new).with({})
    get :new, {}
  end

  def test_permitted_params_from_new
    Widget.expects(:new).with('permitted' => 'param')
    get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_create
    Widget.expects(:new).with('permitted' => 'param').returns(mock(:save => true))
    post :create, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_update
    mock_widget = mock
    mock_widget.stubs(:class).returns(Widget)
    mock_widget.expects(:update_attributes).with('permitted' => 'param')
    mock_widget.stubs(:persisted?).returns(true)
    mock_widget.stubs(:to_model).returns(mock_widget)
    mock_widget.stubs(:model_name).returns(Widget.model_name)
    Widget.expects(:find).with('42').returns(mock_widget)
    put :update, :id => '42', :widget => {:permitted => 'param', :prohibited => 'param'}
  end
end
