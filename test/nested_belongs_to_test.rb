require 'test_helper'

class Country
end

class State
end

class City
  def self.human_name; 'City'; end
end

class CitiesController < InheritedResources::Base
  belongs_to :country, :state
end

class NestedBelongsToTest < ActionController::TestCase
  tests CitiesController

  def setup
    draw_routes do
      resources :cities
    end

    Country.expects(:find).with('13').returns(mock_country)
    mock_country.expects(:states).returns(State)
    State.expects(:find).with('37').returns(mock_state)
    mock_state.expects(:cities).returns(City)

    @controller.stubs(:collection_url).returns('/')
  end

  def teardown
    clear_routes
  end

  def test_assigns_country_and_state_and_city_on_index
    City.expects(:scoped).returns([mock_city])
    get :index, params: { state_id: '37', country_id: '13' }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal [mock_city], assigns(:cities)
  end

  def test_assigns_country_and_state_and_city_on_show
    City.expects(:find).with('42').returns(mock_city)
    get :show, params: { id: '42', state_id: '37', country_id: '13' }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_new
    City.expects(:build).returns(mock_city)
    get :new, params: { state_id: '37', country_id: '13' }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_edit
    City.expects(:find).with('42').returns(mock_city)
    get :edit, params: { id: '42', state_id: '37', country_id: '13' }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_create
    City.expects(:build).with({'these' => 'params'}).returns(mock_city)
    mock_city.expects(:save).returns(true)
    post :create, params: { state_id: '37', country_id: '13', city: {these: 'params'} }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_update
    City.expects(:find).with('42').returns(mock_city)
    mock_city.expects(:update).returns(true)
    put :update, params: { id: '42', state_id: '37', country_id: '13', city: {these: 'params'} }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  def test_assigns_country_and_state_and_city_on_destroy
    City.expects(:find).with('42').returns(mock_city)
    mock_city.expects(:destroy)
    delete :destroy, params: { id: '42', state_id: '37', country_id: '13' }

    assert_equal mock_country, assigns(:country)
    assert_equal mock_state, assigns(:state)
    assert_equal mock_city, assigns(:city)
  end

  protected

    def mock_country(stubs={})
      @mock_country ||= mock(stubs)
    end

    def mock_state(stubs={})
      @mock_state ||= mock(stubs)
    end

    def mock_city(stubs={})
      @mock_city ||= mock(stubs)
    end
end
