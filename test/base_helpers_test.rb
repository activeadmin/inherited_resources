require File.dirname(__FILE__) + '/test_helper'

class Address
  def self.human_name; 'Address'; end
end

class AddressesController < InheritedResources::Base
  protected
    def interpolation_options
      { :reference => 'Ocean Avenue' }
    end
end

module Admin; end
class Admin::AddressesController < InheritedResources::Base
  protected
    def interpolation_options
      { :reference => 'Ocean Avenue' }
    end
end

class FlashBaseHelpersTest < TEST_CLASS

  def setup
    @controller          = AddressesController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
    @request.accept      = 'application/xml'
  end

  def test_success_flash_message_on_create_with_yml
    Address.stubs(:new).returns(mock_address(:save => true))
    @controller.stubs(:address_url)
    post :create
    assert_equal 'You created a new address close to <b>Ocean Avenue</b>.', flash[:notice]
  end

  def test_success_flash_message_on_create_with_namespaced_controller
    @controller = Admin::AddressesController.new
    Address.stubs(:new).returns(mock_address(:save => true))
    @controller.stubs(:address_url)
    post :create
    assert_equal 'Admin, you created a new address close to <b>Ocean Avenue</b>.', flash[:notice]
  end

  def test_failure_flash_message_on_create_with_namespaced_controller_actions
    @controller = Admin::AddressesController.new
    Address.stubs(:new).returns(mock_address(:save => false))
    @controller.stubs(:address_url)
    post :create
    assert_equal 'Admin error message.', flash[:error]
  end

  def test_inherited_success_flash_message_on_update_on_namespaced_controllers
    @controller = Admin::AddressesController.new
    Address.stubs(:find).returns(mock_address(:update_attributes => true))
    put :update
    assert_response :success
    assert_equal 'Nice! Address was updated with success!', flash[:notice]
  end

  def test_success_flash_message_on_update
    Address.stubs(:find).returns(mock_address(:update_attributes => true))
    put :update
    assert_response :success
    assert_equal 'Nice! Address was updated with success!', flash[:notice]
  end

  def test_failure_flash_message_on_update
    Address.stubs(:find).returns(mock_address(:update_attributes => false, :errors => []))
    put :update
    assert_equal 'Oh no! We could not update your address!', flash[:error]
  end

  def test_success_flash_message_on_destroy
    Address.stubs(:find).returns(mock_address(:destroy => true))
    delete :destroy
    assert_equal 'Address was successfully destroyed.', flash[:notice]
  end

  protected
    def mock_address(stubs={})
      @mock_address ||= mock(stubs)
    end

end

class Pet
  def self.human_name; 'Pet'; end
end

class PetsController < InheritedResources::Base
  attr_accessor :current_user
  
  def edit
    @pet = 'new pet'
    edit!
  end

  protected
    def collection
      @pets ||= end_of_association_chain.all
    end

    def begin_of_association_chain
      @current_user
    end
end

class AssociationChainBaseHelpersTest < TEST_CLASS

  def setup
    @controller              = PetsController.new
    @controller.request      = @request  = ActionController::TestRequest.new
    @controller.response     = @response = ActionController::TestResponse.new
    @controller.current_user = mock()
    @request.accept          = 'application/xml'
  end

  def test_begin_of_association_chain_is_called_on_index
    @controller.current_user.expects(:pets).returns(Pet)
    Pet.expects(:all).returns(mock_pet)
    mock_pet.expects(:to_xml).returns('Generated XML')
    get :index
    assert_response :success
    assert 'Generated XML', @response.body.strip
  end

  def test_begin_of_association_chain_is_called_on_new
    @controller.current_user.expects(:pets).returns(Pet)
    Pet.expects(:build).returns(mock_pet)
    mock_pet.expects(:to_xml).returns('Generated XML')
    get :new
    assert_response :success
    assert 'Generated XML', @response.body.strip
  end

  def test_begin_of_association_chain_is_called_on_show
    @controller.current_user.expects(:pets).returns(Pet)
    Pet.expects(:find).with('47').returns(mock_pet)
    mock_pet.expects(:to_xml).returns('Generated XML')
    get :show, :id => '47'
    assert_response :success
    assert 'Generated XML', @response.body.strip
  end

  def test_instance_variable_should_not_be_set_if_already_defined
    @request.accept = 'text/html'
    @controller.current_user.expects(:pets).never
    Pet.expects(:find).never
    get :edit
    assert_response :success
    assert_equal 'new pet', assigns(:pet)
  end

  protected
    def mock_pet(stubs={})
      @mock_pet ||= mock(stubs)
    end

end

