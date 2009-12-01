require File.dirname(__FILE__) + '/test_helper'

class Malarz
  def self.human_name; 'Painter'; end
end

class PaintersController < InheritedResources::Base
  defaults :instance_name => 'malarz', :collection_name => 'malarze',
           :resource_class => Malarz, :route_prefix => nil
end

class DefaultsTest < ActionController::TestCase
  tests PaintersController

  def setup
    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_expose_all_painters_as_instance_variable
    Malarz.expects(:find).with(:all).returns([mock_painter])
    get :index
    assert_equal [mock_painter], assigns(:malarze)
  end

  def test_expose_the_requested_painter_on_show
    Malarz.expects(:find).with('42').returns(mock_painter)
    get :show, :id => '42'
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_new_painter
    Malarz.expects(:new).returns(mock_painter)
    get :new
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_the_requested_painter_on_edit
    Malarz.expects(:find).with('42').returns(mock_painter)
    get :edit, :id => '42'
    assert_response :success
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_newly_create_painter_when_saved_with_success
    Malarz.expects(:new).with({'these' => 'params'}).returns(mock_painter(:save => true))
    post :create, :malarz => {:these => 'params'}
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_update_the_requested_object
    Malarz.expects(:find).with('42').returns(mock_painter)
    mock_painter.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :malarz => {:these => 'params'}
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_the_requested_painter_is_destroyed
    Malarz.expects(:find).with('42').returns(mock_painter)
    mock_painter.expects(:destroy)
    delete :destroy, :id => '42'
    assert_equal mock_painter, assigns(:malarz)
  end

  protected
    def mock_painter(stubs={})
      @mock_painter ||= mock(stubs)
    end
end

