# Now we are going to test aliases defined in base.rb and if overwriting
# methods works properly.
require File.dirname(__FILE__) + '/test_helper'

class Student;
  def self.human_name; 'Student'; end
end

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

  def create
    create! do |success, failure|
      success.html { render :text => "I won't redirect!" }
    end
  end

  def update
    update! do |success, failure|
      failure.html { render :text => "I won't render!" }
    end
  end

  def destroy
    destroy! do |format|
      format.html { render :text => "Destroyed!" }
    end
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

  def test_expose_the_resquested_user_on_edit
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

  def test_is_not_redirected_on_create_with_success_if_success_block_is_given
    Student.stubs(:new).returns(mock_student(:save => true))
    @controller.stubs(:resource_url).returns('http://test.host/')
    post :create
    assert_response :success
    assert_equal "I won't redirect!", @response.body
  end

  def test_dumb_responder_with_quietly_receive_everything_on_failure
    Student.stubs(:new).returns(mock_student(:save => false, :errors => []))
    @controller.stubs(:resource_url).returns('http://test.host/')
    post :create
    assert_response :success
    assert_template :edit
  end

  def test_wont_render_edit_template_on_update_with_failure_if_failure_block_is_given
    Student.stubs(:find).returns(mock_student(:update_attributes => false, :errors => []))
    put :update
    assert_response :success
    assert_equal "I won't render!", @response.body
  end

  def test_dumb_responder_with_quietly_receive_everything_on_success
    Student.stubs(:find).returns(mock_student(:update_attributes => true))
    put :update, :id => '42', :student => {:these => 'params'}
    assert_equal mock_student, assigns(:student)
  end

  def test_block_is_called_when_student_is_destroyed
    Student.stubs(:find).returns(mock_student(:destroy => true))
    delete :destroy
    assert_response :success
    assert_equal "Destroyed!", @response.body
  end

  protected
    def mock_student(stubs={})
      @mock_student ||= mock(stubs)
    end
end

