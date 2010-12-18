require File.expand_path('test_helper', File.dirname(__FILE__))

class Subfaculty
end

class Speciality
end

module Plan
  class Group
  end

  class Education
  end
end

class GroupsController < InheritedResources::Base
  defaults :resource_class => Plan::Group
  belongs_to :subfaculty, :shallow => true do
    belongs_to :speciality
  end
end

class EducationsController < InheritedResources::Base
  defaults :resource_class => Plan::Education
  belongs_to :subfaculty, :shallow => true do
    belongs_to :speciality do
      belongs_to :group, :parent_class => Plan::Group, :instance_name => :plan_group, :param => :group_id
    end
  end
end

class NestedModelWithShallowTest < ActionController::TestCase
  tests GroupsController

  def setup
    mock_speciality.expects(:subfaculty).returns(mock_subfaculty)
    mock_subfaculty.expects(:id).returns('13')

    Subfaculty.expects(:find).with('13').returns(mock_subfaculty)
    mock_subfaculty.expects(:specialities).returns(Speciality)
    mock_speciality.expects(:groups).returns(Plan::Group)

    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_assigns_subfaculty_and_speciality_and_group_on_edit
    should_find_parents
    get :edit, :id => '42'

    assert_equal mock_subfaculty, assigns(:subfaculty)
    assert_equal mock_speciality, assigns(:speciality)
    assert_equal mock_group, assigns(:group)
  end

  protected
    def should_find_parents
      Plan::Group.expects(:find).with('42').returns(mock_group)
      mock_group.expects(:speciality).returns(mock_speciality)
      mock_speciality.expects(:id).returns('37')
      Plan::Group.expects(:find).with('42').returns(mock_group)
      Speciality.expects(:find).with('37').returns(mock_speciality)
    end

    def mock_group(stubs={})
      @mock_group ||= mock(stubs)
    end

    def mock_speciality(stubs={})
      @mock_speciality ||= mock(stubs)
    end

    def mock_subfaculty(stubs={})
      @mock_subfaculty ||= mock(stubs)
    end
end

class TwoNestedModelWithShallowTest < ActionController::TestCase
  tests EducationsController

  def setup
    mock_speciality.expects(:subfaculty).returns(mock_subfaculty)
    mock_subfaculty.expects(:id).returns('13')
    Subfaculty.expects(:find).with('13').returns(mock_subfaculty)
    mock_subfaculty.expects(:specialities).returns(Speciality)
    mock_speciality.expects(:groups).returns(Plan::Group)

    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def test_assigns_subfaculty_and_speciality_and_group_on_new
    should_find_parents
    get :new, :group_id => '42'

    assert_equal mock_subfaculty, assigns(:subfaculty)
    assert_equal mock_speciality, assigns(:speciality)
    assert_equal mock_group, assigns(:plan_group)
    assert_equal mock_education, assigns(:education)
  end


  protected
    def should_find_parents
      Plan::Group.expects(:find).with('42').returns(mock_group)
      mock_group.expects(:speciality).returns(mock_speciality)
      mock_group.expects(:educations).returns(mock_education)
      mock_education.expects(:build).returns(mock_education)
      mock_speciality.expects(:id).returns('37')
      Plan::Group.expects(:find).with('42').returns(mock_group)
      Speciality.expects(:find).with('37').returns(mock_speciality)
    end

    def mock_group(stubs={})
      @mock_group ||= mock(stubs)
    end

    def mock_education(stubs={})
      @mock_education ||= mock(stubs)
    end

    def mock_speciality(stubs={})
      @mock_speciality ||= mock(stubs)
    end

    def mock_subfaculty(stubs={})
      @mock_subfaculty ||= mock(stubs)
    end
end
