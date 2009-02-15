require File.dirname(__FILE__) + '/test_helper'

class Factory; end
class Company; end

class Employee
  def self.human_name; 'Employee'; end
end

class EmployeesController < InheritedResources::Base
  belongs_to :factory, :company, :polymorphic => true
end

# Create a TestHelper module with some helpers
module EmployeeTestHelper
  def setup
    @controller          = EmployeesController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  protected
    def mock_factory(stubs={})
      @mock_factory ||= mock(stubs)
    end

    def mock_employee(stubs={})
      @mock_employee ||= mock(stubs)
    end
end

class IndexActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_expose_all_employees_as_instance_variable
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with(:all).returns([mock_employee])
    get :index, :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal [mock_employee], assigns(:employees)
  end

  def test_controller_should_render_index
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns([mock_employee])
    get :index, :factory_id => '37'
    assert_response :success
    assert_equal 'Index HTML', @response.body.strip
  end

  def test_render_all_employees_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with(:all).returns(mock_employee)
    mock_employee.expects(:to_xml).returns('Generated XML')
    get :index, :factory_id => '37'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class ShowActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_expose_the_resquested_employee
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    get :show, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_controller_should_render_show
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee)
    get :show, :factory_id => '37'
    assert_response :success
    assert_equal 'Show HTML', @response.body.strip
  end

  def test_render_exposed_employee_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:to_xml).returns("Generated XML")
    get :show, :id => '42', :factory_id => '37'
    assert_response :success
    assert_equal 'Generated XML', @response.body
  end
end

class NewActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_expose_a_new_employee
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:build).returns(mock_employee)
    get :new, :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_controller_should_render_new
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:build).returns(mock_employee)
    get :new, :factory_id => '37'
    assert_response :success
    assert_equal 'New HTML', @response.body.strip
  end

  def test_render_exposed_a_new_employee_as_xml_when_mime_type_is_xml
    @request.accept = 'application/xml'
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:build).returns(mock_employee)
    mock_employee.expects(:to_xml).returns("Generated XML")
    get :new, :factory_id => '37'
    assert_equal 'Generated XML', @response.body
    assert_response :success
  end
end

class EditActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_expose_the_resquested_employee
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    get :edit, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
    assert_response :success
  end

  def test_controller_should_render_edit
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee)
    get :edit, :factory_id => '37'
    assert_response :success
    assert_equal 'Edit HTML', @response.body.strip
  end
end

class CreateActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_expose_a_newly_create_employee_when_saved_with_success
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:build).with({'these' => 'params'}).returns(mock_employee(:save => true))
    post :create, :factory_id => '37', :employee => {:these => 'params'}
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_redirect_to_the_created_employee
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:build).returns(mock_employee(:save => true))
    @controller.expects(:resource_url).returns('http://test.host/').times(2)
    post :create, :factory_id => '37'
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:build).returns(mock_employee(:save => true))
    post :create, :factory_id => '37'
    assert_equal flash[:notice], 'Employee was successfully created.'
  end

  def test_render_new_template_when_employee_cannot_be_saved
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:build).returns(mock_employee(:save => false, :errors => []))
    post :create, :factory_id => '37'
    assert_response :success
    assert_template :new
  end

  def test_dont_show_flash_message_when_employee_cannot_be_saved
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:build).returns(mock_employee(:save => false, :errors => []))
    post :create, :factory_id => '37'
    assert flash.empty?
  end
end

class UpdateActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_update_the_requested_object
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :factory_id => '37', :employee => {:these => 'params'}
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_redirect_to_the_created_employee
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:update_attributes => true))
    @controller.expects(:resource_url).returns('http://test.host/')
    put :update, :factory_id => '37'
    assert_redirected_to 'http://test.host/'
  end

  def test_show_flash_message_when_success
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:update_attributes => true))
    put :update, :factory_id => '37'
    assert_equal flash[:notice], 'Employee was successfully updated.'
  end

  def test_render_edit_template_when_employee_cannot_be_saved
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:update_attributes => false, :errors => []))
    put :update, :factory_id => '37'
    assert_response :success
    assert_template :edit
  end

  def test_dont_show_flash_message_when_employee_cannot_be_saved
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:update_attributes => false, :errors => []))
    put :update, :factory_id => '37'
    assert flash.empty?
  end
end

class DestroyActionPolymorphicTest < TEST_CLASS
  include EmployeeTestHelper

  def test_the_resquested_employee_is_destroyed
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:destroy)
    delete :destroy, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_show_flash_message
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:destroy => true))
    delete :destroy, :factory_id => '37'
    assert_equal flash[:notice], 'Employee was successfully destroyed.'
  end

  def test_redirects_to_employees_list
    Factory.stubs(:find).returns(mock_factory(:employees => Employee))
    Employee.stubs(:find).returns(mock_employee(:destroy => true))
    @controller.expects(:collection_url).returns('http://test.host/')
    delete :destroy, :factory_id => '37'
    assert_redirected_to 'http://test.host/'
  end
end
class PolymorphicHelpersTest < TEST_CLASS
  include EmployeeTestHelper

  def test_polymorphic_helpers
    new_factory = Factory.new
    Factory.expects(:find).with('37').returns(new_factory)
    new_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with(:all).returns([mock_employee])
    get :index, :factory_id => '37'

    assert @controller.send(:parent?)
    assert_equal :factory, assigns(:parent_type)
    assert_equal :factory, @controller.send(:parent_type)
    assert_equal Factory, @controller.send(:parent_class)
    assert_equal new_factory, assigns(:factory)
    assert_equal new_factory, @controller.send(:parent)
  end
end
