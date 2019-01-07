require 'test_helper'

class GreatSchool
end

class Professor
  def self.human_name; 'Professor'; end
end

class ProfessorsController < InheritedResources::Base
  belongs_to :school, parent_class: GreatSchool, instance_name: :great_school,
                      finder: :find_by_title!, param: :school_title
end

class CustomizedBelongsToTest < ActionController::TestCase
  tests ProfessorsController

  def setup
    draw_routes do
      resources :professors
    end

    GreatSchool.expects(:find_by_title!).with('nice').returns(mock_school(professors: Professor))
    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_index
    Professor.stubs(:scoped).returns([mock_professor])
    get :index, params: { school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_show
    Professor.stubs(:find).returns(mock_professor)
    get :show, params: { id: 42, school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_new
    Professor.stubs(:build).returns(mock_professor)
    get :new, params: { school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_edit
    Professor.stubs(:find).returns(mock_professor)
    get :edit, params: { id: 42, school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_create
    Professor.stubs(:build).returns(mock_professor(save: true))
    post :create, params: { school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_update
    Professor.stubs(:find).returns(mock_professor(update_attributes: true))
    put :update, params: { id: 42, school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  def test_expose_the_requested_school_with_chosen_instance_variable_on_destroy
    Professor.stubs(:find).returns(mock_professor(destroy: true))
    delete :destroy, params: { id: 42, school_title: 'nice' }
    assert_equal mock_school, assigns(:great_school)
  end

  protected

    def mock_school(stubs={})
      @mock_school ||= mock(stubs)
    end

    def mock_professor(stubs={})
      @mock_professor ||= mock(stubs)
    end
end
