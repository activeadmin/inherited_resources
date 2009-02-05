# Now we are going to test aliases defined in base.rb and if overwriting
# methods works properly.
require File.dirname(__FILE__) + '/test_helper'

class Student; end

class StudentsController < InheritedResources::Base

  def edit
    edit! do |format|
      format.xml { render :text => 'Render XML' }
    end
  end

  def new
    @something = 'magical'
    new!
  end

end

class AliasesBaseTest < TEST_CLASS

  def setup
    @controller          = StudentsController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  def test_assignments_before_calling_alias
    Student.stubs(:new).returns(mock_student)
    get :new
    assert_response :success
    assert_equal 'magical', assigns(:something)
  end

  def test_controller_should_render_new
    Student.stubs(:new).returns(mock_student)
    get :new
    assert_response :success
    assert_equal 'New HTML', @response.body.strip
  end

  def test_expose_the_resquested_user
    Student.expects(:find).with('42').returns(mock_student)
    get :edit, :id => '42'
    assert_equal mock_student, assigns(:student)
    assert_response :success
  end

  def test_controller_should_render_edit
    Student.stubs(:find).returns(mock_student)
    get :edit
    assert_response :success
    assert_equal 'Edit HTML', @response.body.strip
  end

  def test_render_xml_when_it_is_given_as_a_block
    @request.accept = 'application/xml'
    Student.stubs(:find).returns(mock_student)
    get :edit
    assert_response :success
    assert_equal 'Render XML', @response.body
  end

  protected
    def mock_student(stubs={})
      @mock_student ||= mock(stubs)
    end
end

