require File.dirname(__FILE__) + '/test_helper'

# This test file is instead to test the how controller flow and actions
# using a belongs_to association. This is done using mocks a la rspec.
#
class Store
end

class Manager
  def self.human_name; 'Manager'; end
end

class ManagersController < InheritedResources::Base
  belongs_to :store, :singleton => true
end

# Create a TestHelper module with some helpers
module ManagerTestHelper
  def setup
    @controller          = ManagersController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  protected
    def mock_store(stubs={})
      @mock_store ||= mock(stubs)
    end

    def mock_manager(stubs={})
      @mock_manager ||= mock(stubs)
    end
end

class ShowActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_expose_the_resquested_manager
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:manager).returns(mock_manager)
    get :show, :store_id => '37'
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
  end

  def test_controller_should_render_show
    Store.stubs(:find).returns(mock_store(:manager => mock_manager))
    get :show
    assert_response :success
    assert_equal 'Show HTML', @response.body.strip
  end

  def test_render_exposed_manager_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:manager).returns(mock_manager)
    mock_manager.expects(:to_xml).returns("Generated XML")
    get :show, :id => '42', :store_id => '37'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class NewActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_expose_a_new_manager
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:build_manager).returns(mock_manager)
    get :new, :store_id => '37'
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
  end

  def test_controller_should_render_new
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:build_manager).returns(mock_manager)
    get :new
    assert_response :success
    assert_equal 'New HTML', @response.body.strip
  end

  def test_render_exposed_a_new_manager_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:build_manager).returns(mock_manager)
    mock_manager.expects(:to_xml).returns("Generated XML")
    get :new, :store_id => '37'
    assert_equal 'Generated XML', @response.body
    assert_response :success
  end
end

class EditActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_expose_the_resquested_manager
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:manager).returns(mock_manager)
    get :edit, :store_id => '37'
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
    assert_response :success
  end

  def test_controller_should_render_edit
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:manager).returns(mock_manager)
    get :edit
    assert_response :success
    assert_equal 'Edit HTML', @response.body.strip
  end
end

class CreateActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_expose_a_newly_create_manager_when_saved_with_success
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:build_manager).with({'these' => 'params'}).returns(mock_manager(:save => true))
    post :create, :store_id => '37', :manager => {:these => 'params'}
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
  end

  def test_redirect_to_the_created_manager
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:build_manager).returns(mock_manager(:save => true))
    @controller.expects(:resource_url).returns('http://test.host/').times(2)
    post :create
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:build_manager).returns(mock_manager(:save => true))
    post :create
    assert_equal flash[:notice], 'Manager was successfully created.'
  end

  def test_render_new_template_when_manager_cannot_be_saved
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:build_manager).returns(mock_manager(:save => false, :errors => []))
    post :create
    assert_response :success
    assert_template :new
  end

  def test_dont_show_flash_message_when_manager_cannot_be_saved
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:build_manager).returns(mock_manager(:save => false, :errors => []))
    post :create
    assert flash.empty?
  end
end

class UpdateActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_update_the_requested_object
    Store.expects(:find).with('37').returns(mock_store(:manager => mock_manager))
    mock_manager.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :store_id => '37', :manager => {:these => 'params'}
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
  end

  def test_redirect_to_the_created_manager
    Store.expects(:find).returns(mock_store(:manager => mock_manager))
    mock_manager.stubs(:update_attributes).returns(true)
    @controller.expects(:resource_url).returns('http://test.host/')
    put :update
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Store.expects(:find).returns(mock_store(:manager => mock_manager))
    mock_manager.stubs(:update_attributes).returns(true)
    put :update
    assert_equal flash[:notice], 'Manager was successfully updated.'
  end

  def test_render_edit_template_when_manager_cannot_be_saved
    Store.expects(:find).returns(mock_store(:manager => mock_manager(:errors => [])))
    mock_manager.stubs(:update_attributes).returns(false)
    put :update
    assert_response :success
    assert_template :edit
  end

  def test_dont_show_flash_message_when_manager_cannot_be_saved
    Store.expects(:find).returns(mock_store(:manager => mock_manager(:errors => [])))
    mock_manager.stubs(:update_attributes).returns(false)
    put :update
    assert flash.empty?
  end
end

class DestroyActionSingletonTest < TEST_CLASS
  include ManagerTestHelper

  def test_the_resquested_manager_is_destroyed
    Store.expects(:find).with('37').returns(mock_store)
    mock_store.expects(:manager).returns(mock_manager)
    mock_manager.expects(:destroy)
    delete :destroy, :store_id => '37'
    assert_equal mock_store, assigns(:store)
    assert_equal mock_manager, assigns(:manager)
  end

  def test_show_flash_message
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:manager).returns(mock_manager(:destroy => true))
    delete :destroy
    assert_equal flash[:notice], 'Manager was successfully destroyed.'
  end

  def test_redirects_to_store_show
    Store.stubs(:find).returns(mock_store)
    mock_store.stubs(:manager).returns(mock_manager(:destroy => true))
    @controller.expects(:collection_url).returns('http://test.host/')
    delete :destroy
    assert_redirected_to 'http://test.host/'
  end
end

