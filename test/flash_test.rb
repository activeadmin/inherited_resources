require File.dirname(__FILE__) + '/test_helper'

class Address
  def self.human_name; 'Address'; end
end

class AddressesController < InheritedResources::Base
  respond_to :xml
  protected
    def interpolation_options
      { :reference => 'Ocean Avenue' }
    end
end

module Admin; end
class Admin::AddressesController < InheritedResources::Base
  respond_to :xml
  protected
    def interpolation_options
      { :reference => 'Ocean Avenue' }
    end
end

class FlashBaseHelpersTest < ActionController::TestCase
  tests AddressesController

  def setup
    super
    @request.accept = 'application/xml'
    @controller.stubs(:resource_url).returns("http://test.host/")
    @controller.stubs(:collection_url).returns("http://test.host/")
  end

  def test_success_flash_message_on_create_with_yml
    Address.stubs(:new).returns(mock_address(:save => true))
    post :create
    assert_equal 'You created a new address close to <b>Ocean Avenue</b>.', flash[:success]
  end

  def test_success_flash_message_on_create_with_namespaced_controller
    @controller = Admin::AddressesController.new
    @controller.stubs(:resource_url).returns("http://test.host/")
    Address.stubs(:new).returns(mock_address(:save => true))
    post :create
    assert_equal 'Admin, you created a new address close to <b>Ocean Avenue</b>.', flash[:success]
  end

  def test_failure_flash_message_on_create_with_namespaced_controller_actions
    @controller = Admin::AddressesController.new
    @controller.stubs(:resource_url).returns("http://test.host/")
    Address.stubs(:new).returns(mock_address(:save => false))
    post :create
    assert_equal 'Admin error message.', flash[:failure]
  end

  def test_inherited_success_flash_message_on_update_on_namespaced_controllers
    @controller = Admin::AddressesController.new
    @controller.stubs(:resource_url).returns("http://test.host/")
    Address.stubs(:find).returns(mock_address(:update_attributes => true))
    put :update
    assert_response :success
    assert_equal 'Nice! Address was updated with success!', flash[:success]
  end

  def test_success_flash_message_on_update
    Address.stubs(:find).returns(mock_address(:update_attributes => true))
    put :update
    assert_response :success
    assert_equal 'Nice! Address was updated with success!', flash[:success]
  end

  def test_failure_flash_message_on_update
    Address.stubs(:find).returns(mock_address(:update_attributes => false, :errors => {:some => :error}))
    put :update
    assert_equal 'Oh no! We could not update your address!', flash[:failure]
  end

  def test_success_flash_message_on_destroy
    Address.stubs(:find).returns(mock_address(:destroy => true))
    delete :destroy
    assert_equal 'Address was successfully destroyed.', flash[:success]
  end

  protected
    def mock_address(stubs={})
      @mock_address ||= stub(stubs.merge(:to_xml => "xml"))
    end
end
