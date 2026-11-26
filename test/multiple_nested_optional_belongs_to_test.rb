# frozen_string_literal: true
require 'test_helper'

class Mentor
end

class Supervisor
end

class Contractor
end

class Project
  def self.human_name
    "Project"
  end
end

class ProjectsController < InheritedResources::Base
  belongs_to :mentor, :supervisor, :contractor, optional: true
end

class MultipleNestedOptionalTest < ActionController::TestCase
  tests ProjectsController

  def setup
    draw_routes do
      resources :projects
    end

    @controller.stubs(:resource_url).returns('/')
    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  # INDEX
  def test_expose_all_projects_as_instance_variable_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:scoped).returns([mock_project])
    get :index, params: { mentor_id: '37' }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal [mock_project], assigns(:projects)
  end

  def test_expose_all_projects_as_instance_variable_with_supervisor
    Supervisor.expects(:find).with('38').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:scoped).returns([mock_project])
    get :index, params: { supervisor_id: '38' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal [mock_project], assigns(:projects)
  end

  def test_expose_all_projects_as_instance_variable_with_contractor
    Contractor.expects(:find).with('666').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:scoped).returns([mock_project])
    get :index, params: { contractor_id: '666' }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal [mock_project], assigns(:projects)
  end

  def test_expose_all_projects_as_instance_variable_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('42').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:scoped).returns([mock_project])
    get :index, params: { supervisor_id: '37', contractor_id: '42' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal [mock_project], assigns(:projects)
  end

  def test_expose_all_projects_as_instance_variable_without_parents
    Project.expects(:scoped).returns([mock_project])
    get :index

    assert_equal [mock_project], assigns(:projects)
  end

  # SHOW
  def test_expose_the_requested_project_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :show, params: { id: '42', mentor_id: '37' }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :show, params: { id: '42', supervisor_id: '37' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :show, params: { id: '42', contractor_id: '37' }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('42').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('13').returns(mock_project)
    get :show, params: { id: '13', supervisor_id: '37', contractor_id: '42' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_without_parents
    Project.expects(:find).with('13').returns(mock_project)
    get :show, params: { id: '13' }

    assert_equal mock_project, assigns(:project)
  end

  # NEW
  def test_expose_a_new_project_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:build).returns(mock_project)
    get :new, params: { mentor_id: '37' }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_new_project_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:build).returns(mock_project)
    get :new, params: { supervisor_id: '37' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_new_project_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:build).returns(mock_project)
    get :new, params: { contractor_id: '37' }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_new_project_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('42').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:build).returns(mock_project)
    get :new, params: { supervisor_id: '37', contractor_id: '42' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_new_project_without_parents
    Project.expects(:new).returns(mock_project)
    get :new

    assert_equal mock_project, assigns(:project)
  end

  # EDIT
  def test_expose_the_requested_project_for_edition_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :edit, params: { id: '42', mentor_id: '37' }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_for_edition_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :edit, params: { id: '42', supervisor_id: '37' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_for_edition_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    get :edit, params: { id: '42', contractor_id: '37' }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_for_edition_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('42').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('13').returns(mock_project)
    get :edit, params: { id: '13', supervisor_id: '37', contractor_id: '42' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_the_requested_project_for_edition_without_parents
    Project.expects(:find).with('13').returns(mock_project)
    get :edit, params: { id: '13' }

    assert_equal mock_project, assigns(:project)
  end

  # CREATE
  def test_expose_a_newly_created_project_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:build).with(build_parameters({ 'these' => 'params' })).returns(mock_project(save: true))
    post :create, params: { mentor_id: '37', project: { these: 'params' } }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_newly_created_project_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:build).with(build_parameters({ 'these' => 'params' })).returns(mock_project(save: true))
    post :create, params: { supervisor_id: '37', project: { these: 'params' } }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_newly_created_project_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:build).with(build_parameters({ 'these' => 'params' })).returns(mock_project(save: true))
    post :create, params: { contractor_id: '37', project: { these: 'params' } }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_newly_created_project_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('42').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:build).with(build_parameters({ 'these' => 'params' })).returns(mock_project(save: true))
    post :create, params: { supervisor_id: '37', contractor_id: '42', project: { these: 'params' } }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_expose_a_newly_created_project_without_parents
    Project.expects(:new).with(build_parameters({ 'these' => 'params' })).returns(mock_project(save: true))
    post :create, params: { project: { these: 'params' } }

    assert_equal mock_project, assigns(:project)
  end

  # UPDATE
  def test_update_the_requested_project_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:update).with(build_parameters({ 'these' => 'params' })).returns(true)
    put :update, params: { id: '42', mentor_id: '37', project: { these: 'params' } }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_update_the_requested_project_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:update).with(build_parameters({ 'these' => 'params' })).returns(true)
    put :update, params: { id: '42', supervisor_id: '37', project: { these: 'params' } }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_update_the_requested_project_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:update).with(build_parameters({ 'these' => 'params' })).returns(true)
    put :update, params: { id: '42', contractor_id: '37', project: { these: 'params' } }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_update_the_requested_project_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('13').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:update).with(build_parameters({ 'these' => 'params' })).returns(true)
    put :update, params: { id: '42', supervisor_id: '37', contractor_id: '13', project: { these: 'params' } }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  # DESTROY
  def test_the_requested_project_is_destroyed_with_mentor
    Mentor.expects(:find).with('37').returns(mock_mentor)
    mock_mentor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:destroy).returns(true)

    delete :destroy, params: { id: '42', mentor_id: '37' }

    assert_equal mock_mentor, assigns(:mentor)
    assert_equal mock_project, assigns(:project)
  end

  def test_the_requested_project_is_destroyed_with_supervisor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:destroy).returns(true)

    delete :destroy, params: { id: '42', supervisor_id: '37' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_project, assigns(:project)
  end

  def test_the_requested_project_is_destroyed_with_contractor
    Contractor.expects(:find).with('37').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:destroy).returns(true)

    delete :destroy, params: { id: '42', contractor_id: '37' }

    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_the_requested_project_is_destroyed_with_supervisor_and_contractor
    Supervisor.expects(:find).with('37').returns(mock_supervisor)
    mock_supervisor.expects(:contractors).returns(Contractor)
    Contractor.expects(:find).with('13').returns(mock_contractor)
    mock_contractor.expects(:projects).returns(Project)
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:destroy).returns(true)

    delete :destroy, params: { id: '42', supervisor_id: '37', contractor_id: '13' }

    assert_equal mock_supervisor, assigns(:supervisor)
    assert_equal mock_contractor, assigns(:contractor)
    assert_equal mock_project, assigns(:project)
  end

  def test_the_requested_project_is_destroyed_without_parents
    Project.expects(:find).with('42').returns(mock_project)
    mock_project.expects(:destroy).returns(true)

    delete :destroy, params: { id: '42' }

    assert_equal mock_project, assigns(:project)
  end

  protected

    def mock_supervisor(stubs={})
      @mock_supervisor ||= mock(stubs)
    end

    def mock_contractor(stubs={})
      @mock_contractor ||= mock(stubs)
    end

    def mock_mentor(stubs={})
      @mock_mentor ||= mock(stubs)
    end

    def mock_project(stubs={})
      @mock_project ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end
