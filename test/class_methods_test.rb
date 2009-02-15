require File.dirname(__FILE__) + '/test_helper'

class Book; end
class Folder; end

class BooksController < InheritedResources::Base
  actions :index, :show
end

class ReadersController < InheritedResources::Base
  actions :all, :except => [ :edit, :update ]
end

class FoldersController < InheritedResources::Base
end

# For belongs_to tests
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


class ActionsClassMethodTest < ActiveSupport::TestCase
  def test_actions_are_undefined_when_only_option_is_given
    action_methods = BooksController.send(:action_methods)
    assert_equal 2, action_methods.size

    ['index', 'show'].each do |action|
      assert action_methods.include? action
    end
  end

  def test_actions_are_undefined_when_except_option_is_given
    action_methods = ReadersController.send(:action_methods)
    assert_equal 5, action_methods.size

    ['index', 'new', 'show', 'create', 'destroy'].each do |action|
      assert action_methods.include? action
    end
  end
end


class DefaultsClassMethodTest < ActiveSupport::TestCase
  def test_resource_class_is_set_to_nil_when_resource_model_cannot_be_found
    assert_nil ReadersController.send(:resource_class)
  end

  def test_defaults_are_set
    assert Folder, FoldersController.send(:resource_class)
    assert :folder, FoldersController.send(:resources_configuration)[:self][:instance_name]
    assert :folders, FoldersController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_can_be_overwriten
    BooksController.send(:defaults, :resource_class => String, :instance_name => 'string', :collection_name => 'strings')

    assert String, BooksController.send(:resource_class)
    assert :string, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert :strings, BooksController.send(:resources_configuration)[:self][:collection_name]

    BooksController.send(:defaults, :class_name => 'Fixnum', :instance_name => :fixnum, :collection_name => :fixnums)

    assert String, BooksController.send(:resource_class)
    assert :string, BooksController.send(:resources_configuration)[:self][:instance_name]
    assert :strings, BooksController.send(:resources_configuration)[:self][:collection_name]
  end

  def test_defaults_raises_invalid_key
    assert_raise ArgumentError do
      BooksController.send(:defaults, :boom => String)
    end
  end

  def test_url_helpers_are_recreated_when_defaults_change
    InheritedResources::UrlHelpers.expects(:create_resources_url_helpers!).returns(true).once
    BooksController.send(:defaults, :instance_name => 'string', :collection_name => 'strings')
  end
end


class BelongsToClassMethodTest < TEST_CLASS
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
