require File.expand_path('test_helper', File.dirname(__FILE__))

class Widget
  extend ActiveModel::Naming
end

class WidgetsController < InheritedResources::Base
end

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
    Widget.expects(:find).with('42').returns(mock_widget)
    put :update, :id => '42', :widget => {:permitted => 'param', :prohibited => 'param'}
  end
end