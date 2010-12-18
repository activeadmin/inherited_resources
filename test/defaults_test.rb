require File.expand_path('test_helper', File.dirname(__FILE__))

class Malarz
  def self.human_name; 'Painter'; end

  def to_param
    self.slug
  end
end

class PaintersController < InheritedResources::Base
  defaults :instance_name => 'malarz', :collection_name => 'malarze',
           :resource_class => Malarz, :route_prefix => nil,
           :finder => :find_by_slug
end

class DefaultsTest < ActionController::TestCase
  tests PaintersController

  def setup
    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_expose_all_painters_as_instance_variable
    Malarz.expects(:all).returns([mock_painter])
    get :index
    assert_equal [mock_painter], assigns(:malarze)
  end

  def test_expose_the_requested_painter_on_show
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    get :show, :id => 'forty_two'
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_new_painter
    Malarz.expects(:new).returns(mock_painter)
    get :new
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_the_requested_painter_on_edit
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    get :edit, :id => 'forty_two'
    assert_response :success
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_expose_a_newly_create_painter_when_saved_with_success
    Malarz.expects(:new).with({'these' => 'params'}).returns(mock_painter(:save => true))
    post :create, :malarz => {:these => 'params'}
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_update_the_requested_object
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    mock_painter.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => 'forty_two', :malarz => {:these => 'params'}
    assert_equal mock_painter, assigns(:malarz)
  end

  def test_the_requested_painter_is_destroyed
    Malarz.expects(:find_by_slug).with('forty_two').returns(mock_painter)
    mock_painter.expects(:destroy)
    delete :destroy, :id => 'forty_two'
    assert_equal mock_painter, assigns(:malarz)
  end

  protected
    def mock_painter(stubs={})
      @mock_painter ||= mock(stubs)
    end
end

