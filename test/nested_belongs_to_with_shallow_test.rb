# frozen_string_literal: true
require 'test_helper'

class Dresser
end

class Shelf
end

class Plate
end

class PlatesController < InheritedResources::Base
  belongs_to :dresser, :shelf, shallow: true
end

class NestedBelongsToWithShallowTest < ActionController::TestCase
  tests PlatesController

  def setup
    draw_routes do
      resources :plates
    end

    mock_shelf.expects(:dresser).returns(mock_dresser)
    mock_dresser.expects(:to_param).returns('13')

    Dresser.expects(:find).with('13').returns(mock_dresser)
    mock_dresser.expects(:shelves).returns(Shelf)
    mock_shelf.expects(:plates).returns(Plate)

    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_assigns_dresser_and_shelf_and_plate_on_index
    Shelf.expects(:find).with('37').twice.returns(mock_shelf)
    Plate.expects(:scoped).returns([mock_plate])
    get :index, params: { shelf_id: '37' }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal [mock_plate], assigns(:plates)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_show
    should_find_parents
    get :show, params: { id: '42' }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_new
    Plate.expects(:build).returns(mock_plate)
    Shelf.expects(:find).with('37').twice.returns(mock_shelf)
    get :new, params: { shelf_id: '37' }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_edit
    should_find_parents
    get :edit, params: { id: '42' }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_create
    Shelf.expects(:find).with('37').twice.returns(mock_shelf)

    Plate.expects(:build).with(build_parameters({'these' => 'params'})).returns(mock_plate)
    mock_plate.expects(:save).returns(true)
    post :create, params: { shelf_id: '37', plate: {these: 'params'} }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_update
    should_find_parents
    mock_plate.expects(:update).returns(true)
    put :update, params: { id: '42', plate: {these: 'params'} }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  def test_assigns_dresser_and_shelf_and_plate_on_destroy
    should_find_parents
    mock_plate.expects(:destroy)
    delete :destroy, params: { id: '42' }

    assert_equal mock_dresser, assigns(:dresser)
    assert_equal mock_shelf, assigns(:shelf)
    assert_equal mock_plate, assigns(:plate)
  end

  protected

    def should_find_parents
      Plate.expects(:find).with('42').returns(mock_plate)
      mock_plate.expects(:shelf).returns(mock_shelf)
      mock_shelf.expects(:to_param).returns('37')
      Plate.expects(:find).with('42').returns(mock_plate)
      Shelf.expects(:find).with('37').returns(mock_shelf)
    end

    def mock_dresser(stubs={})
      @mock_dresser ||= mock(stubs)
    end

    def mock_shelf(stubs={})
      @mock_shelf ||= mock(stubs)
    end

    def mock_plate(stubs={})
      @mock_plate ||= mock(stubs)
    end

    def build_parameters(hash)
      ActionController::Parameters.new(hash)
    end
end
