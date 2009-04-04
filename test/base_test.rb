require File.dirname(__FILE__) + '/test_helper'

class User
  def self.human_name; 'User'; end
end

class UsersController < InheritedResources::Base
  respond_to :html, :xml
end

module UserTestHelper
  def setup
    @controller          = UsersController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  protected
    def mock_user(stubs={})
      @mock_user ||= mock(stubs)
    end
end

class IndexActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_expose_all_users_as_instance_variable
    User.expects(:find).with(:all).returns([mock_user])
    get :index
    assert_equal [mock_user], assigns(:users)
  end

  def test_controller_should_render_index
    User.stubs(:find).returns([mock_user])
    get :index
    assert_response :success
    assert_equal 'Index HTML', @response.body.strip
  end

  def test_render_all_users_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    User.expects(:find).with(:all).returns(mock_user)
    mock_user.expects(:to_xml).returns('Generated XML')
    get :index
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class ShowActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_expose_the_resquested_user
    User.expects(:find).with('42').returns(mock_user)
    get :show, :id => '42'
    assert_equal mock_user, assigns(:user)
  end

  def test_controller_should_render_show
    User.stubs(:find).returns(mock_user)
    get :show
    assert_response :success
    assert_equal 'Show HTML', @response.body.strip
  end

  def test_render_exposed_user_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    User.expects(:find).with('42').returns(mock_user)
    mock_user.expects(:to_xml).returns("Generated XML")
    get :show, :id => '42'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class NewActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_expose_a_new_user
    User.expects(:new).returns(mock_user)
    get :new
    assert_equal mock_user, assigns(:user)
  end

  def test_controller_should_render_new
    User.stubs(:new).returns(mock_user)
    get :new
    assert_response :success
    assert_equal 'New HTML', @response.body.strip
  end

  def test_render_exposed_a_new_user_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    User.expects(:new).returns(mock_user)
    mock_user.expects(:to_xml).returns("Generated XML")
    get :new
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class EditActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_expose_the_resquested_user
    User.expects(:find).with('42').returns(mock_user)
    get :edit, :id => '42'
    assert_response :success
    assert_equal mock_user, assigns(:user)
  end

  def test_controller_should_render_edit
    User.stubs(:find).returns(mock_user)
    get :edit
    assert_response :success
    assert_equal 'Edit HTML', @response.body.strip
  end
end

class CreateActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_expose_a_newly_create_user_when_saved_with_success
    User.expects(:new).with({'these' => 'params'}).returns(mock_user(:save => true))
    post :create, :user => {:these => 'params'}
    assert_equal mock_user, assigns(:user)
  end

  def test_redirect_to_the_created_user
    User.stubs(:new).returns(mock_user(:save => true))
    @controller.expects(:resource_url).returns('http://test.host/').times(2)
    post :create
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    User.stubs(:new).returns(mock_user(:save => true))
    post :create
    assert_equal flash[:notice], 'User was successfully created.'
  end

  def test_render_new_template_when_user_cannot_be_saved
    User.stubs(:new).returns(mock_user(:save => false, :errors => []))
    post :create
    assert_response :success
    assert_template :new
  end

  def test_dont_show_flash_message_when_user_cannot_be_saved
    User.stubs(:new).returns(mock_user(:save => false, :errors => []))
    post :create
    assert flash.empty?
  end
end

class UpdateActionBaseTest < ActionController::TestCase
  include UserTestHelper

  def test_update_the_requested_object
    User.expects(:find).with('42').returns(mock_user)
    mock_user.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :user => {:these => 'params'}
    assert_equal mock_user, assigns(:user)
  end

  def test_redirect_to_the_created_user
    User.stubs(:find).returns(mock_user(:update_attributes => true))
    @controller.expects(:resource_url).returns('http://test.host/')
    put :update
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    User.stubs(:find).returns(mock_user(:update_attributes => true))
    put :update
    assert_equal flash[:notice], 'User was successfully updated.'
  end

  def test_render_edit_template_when_user_cannot_be_saved
    User.stubs(:find).returns(mock_user(:update_attributes => false, :errors => []))
    put :update
    assert_response :success
    assert_template :edit
  end

  def test_dont_show_flash_message_when_user_cannot_be_saved
    User.stubs(:find).returns(mock_user(:update_attributes => false, :errors => []))
    put :update
    assert flash.empty?
  end
end

class DestroyActionBaseTest < ActionController::TestCase
  include UserTestHelper
  
  def test_the_resquested_user_is_destroyed
    User.expects(:find).with('42').returns(mock_user)
    mock_user.expects(:destroy)
    delete :destroy, :id => '42'
    assert_equal mock_user, assigns(:user)
  end

  def test_show_flash_message
    User.stubs(:find).returns(mock_user(:destroy => true))
    delete :destroy
    assert_equal flash[:notice], 'User was successfully destroyed.'
  end

  def test_redirects_to_users_list
    User.stubs(:find).returns(mock_user(:destroy => true))
    @controller.expects(:collection_url).returns('http://test.host/')
    delete :destroy
    assert_redirected_to 'http://test.host/'
  end
end

