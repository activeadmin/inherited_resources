require File.dirname(__FILE__) + '/test_helper'

class Pet
  def self.human_name; 'Pet'; end
end

class PetsController < InheritedResources::Base
  respond_to :xml
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

class AssociationChainBaseHelpersTest < ActionController::TestCase
  tests PetsController

  def setup
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

