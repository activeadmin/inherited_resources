require File.dirname(__FILE__) + '/test_helper'

class GreatSchool
end

class Professor
  def self.human_name; 'Professor'; end
end

BELONGS_TO_OPTIONS = {
  :parent_class => GreatSchool,
  :instance_name => :great_school,
  :finder => :find_by_title!,
  :param => :school_title
}

class ProfessorsController < InheritedResources::Base
  belongs_to :school, BELONGS_TO_OPTIONS
end

# Create a TestHelper module with some helpers
class BelongsToTest < Test::Unit::TestCase
  def setup
    @controller          = ProfessorsController.new
    @controller.request  = @request  = ActionController::TestRequest.new
    @controller.response = @response = ActionController::TestResponse.new
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:find).returns([mock_professor])
    get :index, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:find).returns(mock_professor)
    get :show, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:build).returns(mock_professor)
    get :new, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:find).returns(mock_professor)
    get :edit, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:build).returns(mock_professor(:save => true))
    post :create, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:find).returns(mock_professor(:update_attributes => true))
    put :update, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_resquested_school_with_chosen_instance_variable
    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(:professors => Professor))
    Professor.stubs(:find).returns(mock_professor(:destroy => true))
    delete :destroy, :school_title => 'nice'
    assert_equal mock_school, assigns(:great_school)
  end

  def test_belongs_to_raise_errors_with_invalid_arguments
    assert_raise ArgumentError do
      ProfessorsController.send(:belongs_to)
    end

    assert_raise ArgumentError do
      ProfessorsController.send(:belongs_to, :arguments, :with_options, :parent_class => Professor)
    end

    assert_raise ArgumentError do
      ProfessorsController.send(:belongs_to, :nice, :invalid_key => '')
    end
  end

  def test_url_helpers_are_recreated_when_defaults_change
    InheritedResources::UrlHelpers.expects(:create_resources_url_helpers!).returns(true).once
    ProfessorsController.send(:defaults, BELONGS_TO_OPTIONS)
  ensure
    # Reestore default settings
    ProfessorsController.send(:parents_symbols=, [:school])
  end

  protected
    def mock_school(stubs={})
      @mock_school ||= mock(stubs)
    end

    def mock_professor(stubs={})
      @mock_professor ||= mock(stubs)
    end
end

