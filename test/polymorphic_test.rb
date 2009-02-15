require File.dirname(__FILE__) + '/test_helper'

class Factory; end
class Company; end

class Employee
  def self.human_name; 'Employee'; end
end

class EmployeesController < InheritedResources::Base
  belongs_to :factory, :company, :polymorphic => true
end

class PolymorphicTest < TEST_CLASS

  def setup
    @controller          = EmployeesController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  def test_expose_all_employees_as_instance_variable_on_index
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with(:all).returns([mock_employee])
    get :index, :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal [mock_employee], assigns(:employees)
  end

  def test_expose_the_resquested_employee_on_show
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    get :show, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_a_new_employee_on_new
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:build).returns(mock_employee)
    get :new, :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_expose_the_resquested_employee_on_edit
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    get :edit, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
    assert_response :success
  end

  def test_expose_a_newly_create_employee_on_create
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:build).with({'these' => 'params'}).returns(mock_employee(:save => true))
    post :create, :factory_id => '37', :employee => {:these => 'params'}
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_update_the_requested_object_on_update
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:update_attributes).with({'these' => 'params'}).returns(true)
    put :update, :id => '42', :factory_id => '37', :employee => {:these => 'params'}
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

  def test_the_resquested_employee_is_destroyed_on_destroy
    Factory.expects(:find).with('37').returns(mock_factory)
    mock_factory.expects(:employees).returns(Employee)
    Employee.expects(:find).with('42').returns(mock_employee)
    mock_employee.expects(:destroy)
    delete :destroy, :id => '42', :factory_id => '37'
    assert_equal mock_factory, assigns(:factory)
    assert_equal mock_employee, assigns(:employee)
  end

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

  protected
    def mock_factory(stubs={})
      @mock_factory ||= mock(stubs)
    end

    def mock_employee(stubs={})
      @mock_employee ||= mock(stubs)
    end
end
