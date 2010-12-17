require File.expand_path('test_helper', File.dirname(__FILE__))

class Subfaculty
end

class Speciality
end

class Speciality::Group
end

class GroupsController < InheritedResources::Base
  defaults :resource_class => Speciality::Group
  belongs_to :subfaculty, :shallow => true do
    belongs_to :speciality
  end
end

class NestedModelWithShallowTest < ActionController::TestCase
  tests GroupsController

  def setup
    mock_speciality.expects(:subfaculty).returns(mock_subfaculty)
    mock_subfaculty.expects(:id).returns('13')

    Subfaculty.expects(:find).with('13').returns(mock_subfaculty)
    mock_subfaculty.expects(:specialities).returns(Speciality)
    mock_speciality.expects(:groups).returns(Speciality::Group)

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
      Speciality::Group.expects(:find).with('42').returns(mock_group)
      mock_group.expects(:speciality).returns(mock_speciality)
      mock_speciality.expects(:id).returns('37')
      Speciality::Group.expects(:find).with('42').returns(mock_group)
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
